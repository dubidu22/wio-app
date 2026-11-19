<?php

declare(strict_types=1);

namespace Wio\Ops;

use DateTimeImmutable;
use DateTimeZone;
use InvalidArgumentException;
use JsonException;
use Psr\Clock\ClockInterface;
use RuntimeException;
use Wio\Database\Sql;
use Wio\Files\ContentRange;
use Wio\Files\FileStore;
use Wio\Schema\NameKey;
use Wio\Schema\RevisionCounter;
use Wio\Support\Time;
use Wio\Support\Uuid;

/**
 * Loads the invented demo workspace of tools/demo/demo-workspace.json (D-78)
 * into an existing, empty workspace on staging, so hand tests have customers,
 * jobs, rooms and pictures before the app can create them (plan 094,
 * D-399..D-408). Reached by bin/seed-demo.
 *
 * - Only where WIO_ENVIRONMENT is "staging", checked before the database is
 *   touched (D-406).
 * - The demo workspace whose plan equals the target's is loaded, without its
 *   workspace and user rows; every user reference becomes the owner (D-400,
 *   D-401).
 * - Every demo id gets a new UUID v7; revisions come from the workspace's
 *   RevisionCounter in the file's revision order; name keys from NameKey
 *   (D-402, D-403).
 * - Dates move by whole days so the file's first job is today in
 *   Europe/Berlin (D-404).
 * - It refuses a workspace that already holds data, so a second run changes
 *   nothing (D-405). One transaction; picture files go into the file store
 *   before the commit (D-408).
 */
final class SeedDemo
{
    public const string ENVIRONMENT = 'staging';

    /** A workspace holding a row in any of these is not empty (D-405). */
    public const array CONTENT_TABLES = ['customers', 'sites', 'rooms', 'entries', 'jobs', 'pictures', 'notes'];

    /** Demo tables that are not loaded (D-400). */
    private const array SKIPPED_TABLES = ['workspaces', 'users'];

    private const string DEMO_ID = '/^01990000-0000-7000-8000-[0-9a-f]{12}$/';

    private const string FILE_TIME = '/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2}\.\d{3})Z$/';

    private const string FILE_DATE = '/^\d{4}-\d{2}-\d{2}$/';

    private const string IDENTIFIER = '/^[a-z][a-z0-9_]*$/';

    private const string SHA256 = '/^[0-9a-f]{64}$/';

    private const string TIME_ZONE = 'Europe/Berlin';

    public const string REFUSED_ENVIRONMENT = 'seed-demo runs only where WIO_ENVIRONMENT is staging.';

    public const string REFUSED_NOT_EMPTY = 'The workspace already holds customers, sites, rooms, entries, jobs, pictures or notes; seed-demo only loads into an empty workspace.';

    public function __construct(
        private readonly string $environment,
        private readonly Sql $sql,
        private readonly ClockInterface $clock,
        private readonly FileStore $files,
        private readonly string $demoFile,
    ) {}

    /**
     * @return array{workspace_id: string, owner_id: string, demo_workspace: string, counts: array<string, int>, job_dates: list<string>, last_revision: int}
     */
    public function run(?string $workspaceId, ?string $email): array
    {
        if ($this->environment !== self::ENVIRONMENT) {
            throw new OpsException(self::REFUSED_ENVIRONMENT);
        }
        if (($workspaceId === null || $workspaceId === '') && ($email === null || trim($email) === '')) {
            throw new OpsException('Name the workspace with --workspace-id or its owner with --email.');
        }
        $demo = $this->readFile();

        return $this->sql->transaction(function () use ($workspaceId, $email, $demo): array {
            [$target, $ownerId, $plan] = $this->owner($workspaceId, $email);
            $this->lockEmpty($target);

            $demoWorkspace = self::demoWorkspace($demo, $plan);
            $tables = self::rowsOf($demo, $demoWorkspace['id']);
            $users = self::userIds($demo, $demoWorkspace['id']);
            $types = $this->columnTypes();
            $now = $this->clock->now();
            $shift = self::dayShift($demo, $now);

            $ids = [$demoWorkspace['id'] => $target];
            foreach ($tables as $rows) {
                foreach ($rows as $row) {
                    $id = $row['id'] ?? null;
                    if (!\is_string($id) || preg_match(self::DEMO_ID, $id) !== 1 || isset($ids[$id])) {
                        throw new InvalidArgumentException('Every demo row needs a unique demo id.');
                    }
                    $ids[$id] = Uuid::v7($now);
                }
            }
            foreach ($users as $userId) {
                $ids[$userId] = $ownerId;
            }

            $revisions = $this->revisions($target, $tables);
            $counts = [];
            $jobDates = [];
            foreach ($tables as $table => $rows) {
                $columns = $types[$table] ?? throw new InvalidArgumentException(sprintf('Table "%s" is not in the database schema.', $table));
                foreach ($rows as $index => $row) {
                    $values = [];
                    foreach ($row as $column => $value) {
                        $type = $columns[$column] ?? null;
                        if ($type === null || $type === 'generated' || \in_array($column, ['name_key', 'email_key'], true)
                            || preg_match(self::IDENTIFIER, $column) !== 1) {
                            throw new InvalidArgumentException(sprintf('Row %d of %s: column "%s" is unknown or derived.', $index, $table, $column));
                        }
                        $values[$column] = $column === 'revision'
                            ? $revisions[$table][$index]
                            : self::value($value, $type, $shift, $ids, "{$table}.{$column}");
                    }
                    if (\in_array($table, ['labels', 'property_keys'], true) && \is_string($row['name'] ?? null)) {
                        $values['name_key'] = NameKey::of($row['name']);
                    }
                    if ($table === 'pictures') {
                        $this->storeFile($target, $row);
                    }
                    if ($table === 'jobs' && \is_string($values['date'] ?? null)) {
                        $jobDates[] = $values['date'];
                    }
                    $this->insert($table, $values);
                    $counts[$table] = ($counts[$table] ?? 0) + 1;
                }
            }
            sort($jobDates);

            $last = $this->sql->row('SELECT last_revision FROM workspace_counters WHERE workspace_id = ?', [$target]);

            return [
                'workspace_id' => $target,
                'owner_id' => $ownerId,
                'demo_workspace' => \is_string($demoWorkspace['name']) ? $demoWorkspace['name'] : '',
                'counts' => $counts,
                'job_dates' => $jobDates,
                'last_revision' => is_numeric($last['last_revision'] ?? null) ? (int) $last['last_revision'] : 0,
            ];
        });
    }

    /**
     * @return array{format: int, tables: list<array{table: string, rows: list<array<string, mixed>>}>}
     */
    private function readFile(): array
    {
        $json = is_file($this->demoFile) ? file_get_contents($this->demoFile) : false;
        if ($json === false) {
            throw new OpsException('The demo file is missing: ' . $this->demoFile);
        }
        try {
            $data = json_decode($json, true, 64, JSON_THROW_ON_ERROR);
        } catch (JsonException $e) {
            throw new InvalidArgumentException('The demo file is not valid JSON.', 0, $e);
        }
        if (!\is_array($data) || ($data['format'] ?? null) !== 1 || !\is_array($data['tables'] ?? null) || !array_is_list($data['tables'])) {
            throw new InvalidArgumentException('The demo file needs format 1 and a "tables" list.');
        }
        $tables = [];
        $seen = [];
        foreach ($data['tables'] as $block) {
            if (!\is_array($block) || !\is_string($block['table'] ?? null) || preg_match(self::IDENTIFIER, $block['table']) !== 1
                || isset($seen[$block['table']]) || !\is_array($block['rows'] ?? null) || !array_is_list($block['rows'])) {
                throw new InvalidArgumentException('Every table block needs a unique "table" and a "rows" list.');
            }
            $seen[$block['table']] = true;
            $rows = [];
            foreach ($block['rows'] as $row) {
                if (!\is_array($row) || $row === [] || array_is_list($row)) {
                    throw new InvalidArgumentException(sprintf('A row of %s is not an object.', $block['table']));
                }
                $clean = [];
                foreach ($row as $column => $value) {
                    $clean[(string) $column] = $value;
                }
                $rows[] = $clean;
            }
            $tables[] = ['table' => $block['table'], 'rows' => $rows];
        }

        return ['format' => 1, 'tables' => $tables];
    }

    /**
     * The target workspace, its owner and its plan (D-399).
     *
     * @return array{string, string, string}
     */
    private function owner(?string $workspaceId, ?string $email): array
    {
        $emailKey = $email === null || trim($email) === '' ? null : NameKey::of($email);
        if ($workspaceId !== null && $workspaceId !== '') {
            $workspace = $this->sql->row('SELECT id, plan FROM workspaces WHERE id = ? AND deleted_at IS NULL', [$workspaceId]);
            if ($workspace === null) {
                throw new OpsException('No workspace has this id.');
            }
            $owners = $this->sql->rows(
                "SELECT id, workspace_id FROM users WHERE workspace_id = ? AND role = 'owner' AND deleted_at IS NULL"
                . ($emailKey === null ? '' : ' AND email_key = ?'),
                $emailKey === null ? [$workspaceId] : [$workspaceId, $emailKey],
            );
            if ($owners === []) {
                throw new OpsException($emailKey === null ? 'The workspace has no owner.' : 'The workspace has no owner with this e-mail.');
            }
            if (\count($owners) > 1) {
                throw new OpsException('The workspace has more than one owner; name one with --email.');
            }
        } else {
            $owners = $this->sql->rows(
                "SELECT u.id, u.workspace_id FROM users u JOIN workspaces w ON w.id = u.workspace_id
                 WHERE u.email_key = ? AND u.role = 'owner' AND u.deleted_at IS NULL AND w.deleted_at IS NULL",
                [(string) $emailKey],
            );
            if ($owners === []) {
                throw new OpsException('No owner has this e-mail.');
            }
            if (\count($owners) > 1) {
                throw new OpsException('Owners in more than one workspace have this e-mail; name the workspace with --workspace-id.');
            }
            $workspace = $this->sql->row('SELECT id, plan FROM workspaces WHERE id = ?', [Sql::text($owners[0]['workspace_id'])]);
        }

        return [Sql::text($owners[0]['workspace_id']), Sql::text($owners[0]['id']), Sql::text($workspace['plan'] ?? '')];
    }

    /**
     * Locks the workspace's counter for the whole run and refuses a
     * workspace that holds data (D-405).
     */
    private function lockEmpty(string $workspaceId): void
    {
        if ($this->sql->row('SELECT last_revision FROM workspace_counters WHERE workspace_id = ? FOR UPDATE', [$workspaceId]) === null) {
            throw new OpsException('The workspace has no revision counter.');
        }
        foreach (self::CONTENT_TABLES as $table) {
            if ($this->sql->row("SELECT 1 FROM {$table} WHERE workspace_id = ? LIMIT 1", [$workspaceId]) !== null) {
                throw new OpsException(self::REFUSED_NOT_EMPTY);
            }
        }
    }

    /**
     * @param array{format: int, tables: list<array{table: string, rows: list<array<string, mixed>>}>} $demo
     * @return array<string, mixed>
     */
    private static function demoWorkspace(array $demo, string $plan): array
    {
        foreach ($demo['tables'] as $block) {
            if ($block['table'] !== 'workspaces') {
                continue;
            }
            foreach ($block['rows'] as $row) {
                if (($row['plan'] ?? null) === $plan && \is_string($row['id'] ?? null)) {
                    return $row;
                }
            }
        }

        throw new OpsException(sprintf('The demo file has no workspace with the plan "%s".', $plan));
    }

    /**
     * Rows of one demo workspace per table, in the file's insert order,
     * without the skipped tables.
     *
     * @param array{format: int, tables: list<array{table: string, rows: list<array<string, mixed>>}>} $demo
     * @return array<string, list<array<string, mixed>>>
     */
    private static function rowsOf(array $demo, mixed $demoWorkspaceId): array
    {
        $tables = [];
        foreach ($demo['tables'] as $block) {
            if (\in_array($block['table'], self::SKIPPED_TABLES, true)) {
                continue;
            }
            $rows = array_values(array_filter($block['rows'], static fn(array $row): bool => ($row['workspace_id'] ?? null) === $demoWorkspaceId));
            if ($rows !== []) {
                $tables[$block['table']] = $rows;
            }
        }

        return $tables;
    }

    /**
     * @param array{format: int, tables: list<array{table: string, rows: list<array<string, mixed>>}>} $demo
     * @return list<string>
     */
    private static function userIds(array $demo, mixed $demoWorkspaceId): array
    {
        $ids = [];
        foreach ($demo['tables'] as $block) {
            if ($block['table'] !== 'users') {
                continue;
            }
            foreach ($block['rows'] as $row) {
                if (($row['workspace_id'] ?? null) === $demoWorkspaceId && \is_string($row['id'] ?? null)) {
                    $ids[] = $row['id'];
                }
            }
        }

        return $ids;
    }

    /**
     * Whole days from the file's first job date to today in Europe/Berlin
     * (D-404).
     *
     * @param array{format: int, tables: list<array{table: string, rows: list<array<string, mixed>>}>} $demo
     */
    private static function dayShift(array $demo, DateTimeImmutable $now): int
    {
        $first = null;
        foreach ($demo['tables'] as $block) {
            if ($block['table'] !== 'jobs') {
                continue;
            }
            foreach ($block['rows'] as $row) {
                $date = $row['date'] ?? null;
                if (\is_string($date) && preg_match(self::FILE_DATE, $date) === 1 && ($first === null || $date < $first)) {
                    $first = $date;
                }
            }
        }
        if ($first === null) {
            return 0;
        }
        $utc = new DateTimeZone('UTC');
        $today = new DateTimeImmutable($now->setTimezone(new DateTimeZone(self::TIME_ZONE))->format('Y-m-d'), $utc);
        $from = new DateTimeImmutable($first, $utc);

        return intdiv($today->getTimestamp() - $from->getTimestamp(), 86400);
    }

    /**
     * One new revision per row, handed out in the file's revision order
     * (D-403).
     *
     * @param array<string, list<array<string, mixed>>> $tables
     * @return array<string, array<int, int>>
     */
    private function revisions(string $workspaceId, array $tables): array
    {
        $order = [];
        foreach ($tables as $table => $rows) {
            foreach ($rows as $index => $row) {
                $revision = $row['revision'] ?? null;
                if (!\is_int($revision)) {
                    throw new InvalidArgumentException(sprintf('Row %d of %s has no revision.', $index, $table));
                }
                $order[] = [$revision, \count($order), $table, $index];
            }
        }
        sort($order);
        $counter = new RevisionCounter($this->sql->pdo);
        $revisions = [];
        foreach ($order as [, , $table, $index]) {
            $revisions[$table][$index] = $counter->next($workspaceId);
        }

        return $revisions;
    }

    /**
     * @param array<string, string> $ids demo id => new id
     */
    private static function value(mixed $value, string $type, int $shift, array $ids, string $where): string|int|null
    {
        if ($value === null || \is_int($value)) {
            return $value;
        }
        if (\is_float($value)) {
            return (string) $value;
        }
        if (\is_array($value)) {
            return json_encode($value, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        if (!\is_string($value)) {
            throw new InvalidArgumentException(sprintf('%s holds a value of an unsupported type.', $where));
        }
        if (preg_match(self::DEMO_ID, $value) === 1) {
            return $ids[$value] ?? throw new InvalidArgumentException(sprintf('%s refers to an unknown demo id.', $where));
        }
        $utc = new DateTimeZone('UTC');
        if ($type === 'datetime') {
            if (preg_match(self::FILE_TIME, $value, $m) !== 1) {
                throw new InvalidArgumentException(sprintf('%s is not an ISO-8601 UTC time with milliseconds.', $where));
            }
            $time = new DateTimeImmutable($m[1] . ' ' . $m[2], $utc);

            return Time::toDatabase($time->modify(sprintf('%+d days', $shift)));
        }
        if ($type === 'date') {
            if (preg_match(self::FILE_DATE, $value) !== 1) {
                throw new InvalidArgumentException(sprintf('%s is not a date.', $where));
            }

            return (new DateTimeImmutable($value, $utc))->modify(sprintf('%+d days', $shift))->format('Y-m-d');
        }

        return $value;
    }

    /**
     * Puts a picture's file into the file store, hash-checked (D-408).
     *
     * @param array<string, mixed> $row
     */
    private function storeFile(string $workspaceId, array $row): void
    {
        $sha = $row['file_sha256'] ?? null;
        if (!\is_string($sha) || preg_match(self::SHA256, $sha) !== 1) {
            throw new InvalidArgumentException('A demo picture has no valid file_sha256.');
        }
        $path = \dirname($this->demoFile) . '/media/' . $sha . '.jpg';
        $bytes = is_file($path) ? file_get_contents($path) : false;
        if ($bytes === false || $bytes === '' || hash('sha256', $bytes) !== $sha) {
            throw new OpsException(sprintf('The demo picture file %s.jpg is missing or does not match its hash.', $sha));
        }
        $size = \strlen($bytes);
        if ($size > FileStore::MAX_CHUNK_BYTES) {
            throw new OpsException(sprintf('The demo picture file %s.jpg is larger than one chunk.', $sha));
        }
        $state = $this->files->put($workspaceId, $sha, ContentRange::parse(sprintf('bytes 0-%d/%d', $size - 1, $size)), $bytes);
        if (!$state['complete']) {
            throw new RuntimeException('A demo picture file did not complete.');
        }
    }

    /**
     * Data type per column per table; generated columns are "generated".
     *
     * @return array<string, array<string, string>>
     */
    private function columnTypes(): array
    {
        $types = [];
        $rows = $this->sql->rows(
            "SELECT TABLE_NAME AS t, COLUMN_NAME AS c, IF(IS_GENERATED = 'NEVER', DATA_TYPE, 'generated') AS d
             FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()",
        );
        foreach ($rows as $row) {
            $types[Sql::text($row['t'])][Sql::text($row['c'])] = strtolower(Sql::text($row['d']));
        }

        return $types;
    }

    /**
     * @param array<string, string|int|null> $values column names allow-listed against the schema
     */
    private function insert(string $table, array $values): void
    {
        $columns = array_keys($values);
        $this->sql->run(
            sprintf(
                'INSERT INTO `%s` (`%s`) VALUES (%s)',
                $table,
                implode('`, `', $columns),
                implode(', ', array_fill(0, \count($columns), '?')),
            ),
            array_values($values),
        );
    }
}
