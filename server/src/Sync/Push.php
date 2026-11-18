<?php

declare(strict_types=1);

namespace Wio\Sync;

use DateInterval;
use PDOException;
use Psr\Clock\ClockInterface;
use RuntimeException;
use Wio\Auth\AuthContext;
use Wio\Database\Sql;
use Wio\Schema\NameKey;
use Wio\Schema\RevisionCounter;
use Wio\Support\Time;
use Wio\Support\Uuid;

/**
 * POST /sync/push (plan 006, D-172 to D-181). Each change runs in its own
 * transaction (D-174), which first locks the workspace's revision counter:
 * writers of one workspace are serialized for the whole change, so they
 * cannot deadlock on each other's records, and revisions commit in order
 * (D-52). Every answer is remembered under its change_id (D-172): a retry
 * gets the stored answer, including a stored rejection, so the app re-creates
 * a rejected change with a new change_id.
 */
final class Push
{
    public const int MAX_CHANGES = 200;

    public const int MAX_BYTES = 2 * 1024 * 1024;

    public const int RETENTION_DAYS = 180;

    public const int PURGE_LIMIT = 1000;

    /** MariaDB errors that mean "this value breaks a rule of the schema": the change is invalid, the server is fine. */
    private const array CONSTRAINT_ERRORS = [1048, 1263, 1264, 1265, 1292, 1364, 1366, 1406, 1451, 1452, 3819, 4025];

    private const int DUPLICATE_KEY = 1062;

    /** Deadlock and lock wait timeout: the change is tried once more (D-174). */
    private const array RETRY_ERRORS = [1205, 1213];

    private readonly RevisionCounter $revisions;

    public function __construct(private readonly Sql $sql, private readonly ClockInterface $clock)
    {
        $this->revisions = new RevisionCounter($sql->pdo);
    }

    /**
     * @param list<Change> $changes
     *
     * @return list<ChangeResult> one per change, in request order
     */
    public function push(AuthContext $caller, array $changes): array
    {
        $this->purge();
        $results = [];
        foreach ($changes as $change) {
            $results[] = $this->one($caller, $change);
        }

        return $results;
    }

    /**
     * Deletes remembered answers older than 180 days, at most 1,000 per push
     * (D-172).
     */
    private function purge(): void
    {
        $cutoff = $this->clock->now()->sub(new DateInterval('P' . self::RETENTION_DAYS . 'D'));
        $this->sql->run(
            'DELETE FROM applied_changes WHERE created_at < ? ORDER BY created_at LIMIT ' . self::PURGE_LIMIT,
            [Time::toDatabase($cutoff)],
        );
    }

    private function one(AuthContext $caller, Change $change): ChangeResult
    {
        try {
            return $this->attempt($caller, $change);
        } catch (PDOException $e) {
            if (!\in_array($e->errorInfo[1] ?? null, self::RETRY_ERRORS, true)) {
                throw $e;
            }
        }

        return $this->attempt($caller, $change);
    }

    private function attempt(AuthContext $caller, Change $change): ChangeResult
    {
        $pdo = $this->sql->pdo;
        $pdo->beginTransaction();
        try {
            $this->lockCounter($caller->workspaceId);
            $known = $this->known($caller, $change);
            if ($known !== null) {
                $pdo->commit();

                return $known;
            }
            $result = $this->apply($caller, $change);
            $this->remember($caller, $change, $result);
            $pdo->commit();

            return $result;
        } catch (Rejected $rejection) {
            $pdo->rollBack();

            return $this->rememberRejection($caller, $change, $rejection);
        } catch (\Throwable $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            throw $e;
        }
    }

    /**
     * A rejection is remembered in a transaction of its own, after the
     * change's work was rolled back.
     */
    private function rememberRejection(AuthContext $caller, Change $change, Rejected $rejection): ChangeResult
    {
        return $this->sql->transaction(function () use ($caller, $change, $rejection): ChangeResult {
            $this->lockCounter($caller->workspaceId);
            $known = $this->known($caller, $change);
            if ($known !== null) {
                return $known;
            }
            $result = ChangeResult::rejected($change->changeId, $rejection);
            $this->remember($caller, $change, $result);

            return $result;
        });
    }

    private function lockCounter(string $workspaceId): void
    {
        if ($this->sql->row('SELECT last_revision FROM workspace_counters WHERE workspace_id = ? FOR UPDATE', [$workspaceId]) === null) {
            throw new RuntimeException('The workspace has no revision counter.');
        }
    }

    /**
     * The stored answer to a change_id this workspace has seen (D-172).
     */
    private function known(AuthContext $caller, Change $change): ?ChangeResult
    {
        $row = $this->sql->row(
            'SELECT payload_sha256, status, revision, reason, existing_id FROM applied_changes WHERE workspace_id = ? AND change_id = ?',
            [$caller->workspaceId, $change->changeId],
        );
        if ($row === null) {
            return null;
        }
        if ($row['payload_sha256'] !== $change->payloadHash()) {
            return ChangeResult::rejected($change->changeId, Rejected::invalid('change_id reused with another payload.'));
        }

        return new ChangeResult(
            $change->changeId,
            Sql::text($row['status']),
            self::intOrNull($row['revision']),
            Sql::textOrNull($row['reason']),
            Sql::textOrNull($row['existing_id']),
        );
    }

    private function remember(AuthContext $caller, Change $change, ChangeResult $result): void
    {
        $this->sql->run(
            'INSERT INTO applied_changes (workspace_id, change_id, device_id, payload_sha256, status, revision, reason, existing_id, created_at)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                $caller->workspaceId,
                $change->changeId,
                $caller->deviceId,
                $change->payloadHash(),
                $result->status,
                $result->revision,
                $result->reason,
                $result->existingId,
                $this->now(),
            ],
        );
    }

    /**
     * @throws Rejected
     */
    private function apply(AuthContext $caller, Change $change): ChangeResult
    {
        $table = self::table($change->entity);
        if ($table === null) {
            throw Rejected::invalid('Unknown entity.');
        }
        if (!\in_array($change->op, ['upsert', 'delete', 'restore', 'move_entry'], true)) {
            throw Rejected::invalid('Unknown op.');
        }
        if ($change->op === 'move_entry' && $table !== 'entries') {
            throw Rejected::invalid('move_entry is only for entries.');
        }
        if (!Rights::mayPush($caller, $table, $change->op)) {
            throw Rejected::permission("This role may not {$change->op} {$table}.");
        }

        $stored = $this->sql->row("SELECT * FROM {$table} WHERE id = ? FOR UPDATE", [$change->id]);
        $workspace = $stored === null ? null : ($table === 'workspaces' ? $stored['id'] : $stored['workspace_id']);
        if ($stored !== null && $workspace !== $caller->workspaceId) {
            // Never tell which workspace holds the id.
            throw $change->op === 'upsert' ? Rejected::invalid('The id cannot be used.') : Rejected::notFound();
        }

        return match ($change->op) {
            'upsert' => $this->upsert($caller, $change, $table, $stored),
            'move_entry' => $this->move($caller, $change, $stored),
            default => $this->tombstone($caller, $change, $table, $stored),
        };
    }

    /**
     * Creates the record or changes the given fields (D-176).
     *
     * @param array<string, mixed>|null $stored
     *
     * @throws Rejected
     */
    private function upsert(AuthContext $caller, Change $change, string $table, ?array $stored): ChangeResult
    {
        if ($stored !== null && $stored['deleted_at'] !== null) {
            throw Rejected::deleted();
        }
        $fields = Fields::check($table, 'upsert', $change->fields);
        $write = [];
        foreach (RecordSchemas::FIELDS[$table] as $column => $schema) {
            if (\array_key_exists($column, $fields)) {
                $write[$column] = Fields::toDatabase($schema, $fields[$column]);
            }
        }
        $pushed = array_keys($write);

        $customerId = $this->customer($caller, $table, $stored, $write);
        $entityType = $table === 'entity_labels' ? self::after('entity_type', $write, $stored) : null;
        if (!Rights::mayChange($caller, $table, 'upsert', $stored, $customerId, array_keys($fields), \is_string($entityType) ? $entityType : null)) {
            throw Rejected::permission('This role may not change this record.');
        }
        if (\in_array($table, Entities::NAME_KEYED, true)) {
            if (\array_key_exists('name', $write)) {
                $write['name_key'] = NameKey::of((string) $write['name']);
            } elseif ($stored === null) {
                throw Rejected::invalid('name is required.');
            }
        }

        $now = $this->now();
        $revision = $this->revisions->next($caller->workspaceId);
        $common = ['updated_at' => $now, 'updated_by' => $caller->userId, 'revision' => $revision];
        try {
            if ($stored === null) {
                $row = ['id' => $change->id, 'workspace_id' => $caller->workspaceId]
                    + $write
                    + ['created_at' => $now, 'created_by' => $caller->userId]
                    + $common;
                $this->sql->run(
                    "INSERT INTO {$table} (" . implode(', ', array_keys($row)) . ') VALUES (' . implode(', ', array_fill(0, \count($row), '?')) . ')',
                    array_values($row),
                );
            } else {
                $this->update($table, $change->id, $write + $common);
            }
        } catch (PDOException $e) {
            throw $this->constraint($e, $caller->workspaceId, $table, $change->id, $write + ($stored ?? []));
        }

        $this->versions($caller, $change, $table, $stored, $pushed, $revision, $customerId);

        return new ChangeResult($change->changeId, $this->status($stored, $change), $revision);
    }

    /**
     * delete sets the tombstone, restore clears it; neither cascades (D-176).
     * A record already in the asked state answers applied with its revision.
     *
     * @param array<string, mixed>|null $stored
     *
     * @throws Rejected
     */
    private function tombstone(AuthContext $caller, Change $change, string $table, ?array $stored): ChangeResult
    {
        if ($stored === null) {
            throw Rejected::notFound();
        }
        $customerId = Entities::hasCustomer($table) ? Sql::textOrNull($stored['customer_id'] ?? null) : null;
        $entityType = $table === 'entity_labels' ? Sql::textOrNull($stored['entity_type'] ?? null) : null;
        if (!Rights::mayChange($caller, $table, $change->op, $stored, $customerId, [], $entityType)) {
            throw Rejected::permission('This role may not change this record.');
        }
        Fields::check($table, $change->op, $change->fields);

        $delete = $change->op === 'delete';
        if (($stored['deleted_at'] !== null) === $delete) {
            return new ChangeResult($change->changeId, ChangeResult::APPLIED, self::int($stored['revision']));
        }
        $now = $this->now();
        $revision = $this->revisions->next($caller->workspaceId);
        try {
            $this->update($table, $change->id, [
                'deleted_at' => $delete ? $now : null,
                'updated_at' => $now,
                'updated_by' => $caller->userId,
                'revision' => $revision,
            ]);
        } catch (PDOException $e) {
            throw $this->constraint($e, $caller->workspaceId, $table, $change->id, $stored);
        }

        return new ChangeResult($change->changeId, $this->status($stored, $change), $revision);
    }

    /**
     * Moves an entry: its place and one place_history row in the same
     * transaction (D-54, D-176). The seven place fields are one value: a
     * field the change leaves out becomes null.
     *
     * @param array<string, mixed>|null $stored
     *
     * @throws Rejected
     */
    private function move(AuthContext $caller, Change $change, ?array $stored): ChangeResult
    {
        if ($stored === null) {
            throw Rejected::notFound();
        }
        if ($stored['deleted_at'] !== null) {
            throw Rejected::deleted();
        }
        $customerId = Sql::textOrNull($stored['customer_id']);
        if (!Rights::mayChange($caller, 'entries', 'move_entry', $stored, $customerId, [], null)) {
            throw Rejected::permission('This role may not move this entry.');
        }
        $place = Fields::check('entries', 'move_entry', $change->fields);
        $write = [];
        $same = true;
        foreach (Fields::PLACE as $column) {
            $write[$column] = Fields::toDatabase(RecordSchemas::FIELDS['entries'][$column], $place[$column]);
            $same = $same && self::scalar($write[$column]) === self::scalar($stored[$column]);
        }
        if ($write['site_id'] !== null && $this->customerOf($caller->workspaceId, 'sites', (string) $write['site_id'], 'site_id') !== $customerId) {
            throw Rejected::invalid('customer_id does not match the parent.');
        }
        if ($same) {
            return new ChangeResult($change->changeId, ChangeResult::APPLIED, self::int($stored['revision']));
        }

        $now = $this->now();
        $revision = $this->revisions->next($caller->workspaceId);
        $history = ['id' => Uuid::v7($this->clock->now()), 'workspace_id' => $caller->workspaceId, 'customer_id' => $customerId, 'entry_id' => $change->id];
        foreach (Fields::PLACE as $column) {
            $history['from_' . $column] = self::scalar($stored[$column]);
        }
        foreach (Fields::PLACE as $column) {
            $history['to_' . $column] = $write[$column];
        }
        $history += [
            'moved_at' => $now,
            'moved_by' => $caller->userId,
            'created_at' => $now,
            'created_by' => $caller->userId,
            'updated_at' => $now,
            'updated_by' => $caller->userId,
        ];
        try {
            $this->update('entries', $change->id, $write + ['updated_at' => $now, 'updated_by' => $caller->userId, 'revision' => $revision]);
            $history['revision'] = $this->revisions->next($caller->workspaceId);
            $this->sql->run(
                'INSERT INTO place_history (' . implode(', ', array_keys($history)) . ') VALUES (' . implode(', ', array_fill(0, \count($history), '?')) . ')',
                array_values($history),
            );
        } catch (PDOException $e) {
            throw $this->constraint($e, $caller->workspaceId, 'entries', $change->id, $write + $stored);
        }

        $this->versions($caller, $change, 'entries', $stored, Fields::PLACE, $revision, $customerId);

        return new ChangeResult($change->changeId, $this->status($stored, $change), $revision);
    }

    /**
     * The record's customer after the change (D-178): taken from the parent
     * or subject where there is one, else from `fields`. A pushed
     * customer_id that differs from the parent's is invalid; an omitted one
     * is filled in. Also checks that a subject exists and is alive (D-180).
     *
     * @param array<string, mixed>|null $stored
     * @param array<string, string|int|null> $write the columns to write; customer_id is set here
     *
     * @throws Rejected
     */
    private function customer(AuthContext $caller, string $table, ?array $stored, array &$write): ?string
    {
        if (!Entities::hasCustomer($table)) {
            return null;
        }
        $derived = null;
        $found = false;
        foreach (Entities::PARENTS[$table] ?? [] as [$column, $parent]) {
            $parentId = self::after($column, $write, $stored);
            if ($parentId !== null) {
                $derived = $this->customerOf($caller->workspaceId, $parent, (string) $parentId, $column);
                $found = true;
                break;
            }
        }
        if (isset(Entities::SUBJECTS[$table])) {
            [$typeColumn, $idColumn, $tables] = Entities::SUBJECTS[$table];
            $type = self::after($typeColumn, $write, $stored);
            $id = self::after($idColumn, $write, $stored);
            if ($type === null || $id === null) {
                throw Rejected::invalid("{$typeColumn} and {$idColumn} are required.");
            }
            $subjectTable = $tables[(string) $type] ?? throw Rejected::invalid("Unknown {$typeColumn}.");
            $changed = $stored === null || \array_key_exists($typeColumn, $write) || \array_key_exists($idColumn, $write);
            $derived = $this->customerOfSubject($caller, $subjectTable, (string) $id, $changed);
            $found = true;
        }

        if (!$found) {
            if (isset(Entities::PARENTS[$table]) && !\in_array($table, Entities::PARENT_OPTIONAL, true)) {
                throw Rejected::invalid(Entities::PARENTS[$table][0][0] . ' is required.');
            }
            $own = self::after('customer_id', $write, $stored);

            return $own === null ? null : (string) $own;
        }
        if (\array_key_exists('customer_id', $write) && $write['customer_id'] !== $derived) {
            throw Rejected::invalid('customer_id does not match the parent.');
        }
        if ($stored === null || ($stored['customer_id'] ?? null) !== $derived) {
            $write['customer_id'] = $derived;
        }

        return $derived;
    }

    /**
     * @throws Rejected
     */
    private function customerOf(string $workspaceId, string $parent, string $id, string $column): ?string
    {
        $row = $this->sql->row("SELECT customer_id FROM {$parent} WHERE workspace_id = ? AND id = ?", [$workspaceId, $id]);
        if ($row === null) {
            throw Rejected::invalid("{$column} points to no record of this workspace.");
        }

        return Sql::textOrNull($row['customer_id']);
    }

    /**
     * The subject of a link or note must exist in this workspace and, when
     * the link is made or re-pointed, be alive (D-180). A customer is its
     * own customer.
     *
     * @throws Rejected
     */
    private function customerOfSubject(AuthContext $caller, string $subjectTable, string $id, bool $mustBeAlive): ?string
    {
        $column = $subjectTable === 'customers' ? 'id' : 'customer_id';
        $row = $this->sql->row(
            "SELECT {$column} AS customer_id, deleted_at FROM {$subjectTable} WHERE workspace_id = ? AND id = ?",
            [$caller->workspaceId, $id],
        );
        if ($row === null) {
            throw Rejected::invalid('The subject does not exist in this workspace.');
        }
        if ($mustBeAlive && $row['deleted_at'] !== null) {
            throw Rejected::invalid('The subject is deleted.');
        }

        return Sql::textOrNull($row['customer_id']);
    }

    /**
     * Records the revision of every written field, and a conflict for each
     * field that another device wrote after the change's base revision with
     * another value (D-173): the incoming value has won, the stored one is
     * kept in `conflicts`.
     *
     * @param array<string, mixed>|null $stored
     * @param list<string> $columns the written fields
     */
    private function versions(AuthContext $caller, Change $change, string $table, ?array $stored, array $columns, int $revision, ?string $customerId): void
    {
        if ($stored !== null) {
            $after = $this->sql->row("SELECT * FROM {$table} WHERE id = ?", [$change->id]) ?? [];
            $base = $change->baseRevision ?? 0;
            foreach ($columns as $column) {
                $version = $this->sql->row(
                    'SELECT f.revision, f.change_id, a.device_id FROM field_versions f
                     LEFT JOIN applied_changes a ON a.workspace_id = f.workspace_id AND a.change_id = f.change_id
                     WHERE f.workspace_id = ? AND f.entity = ? AND f.entity_id = ? AND f.field = ?',
                    [$caller->workspaceId, $table, $change->id, $column],
                );
                if ($version === null || self::int($version['revision']) <= $base || $version['device_id'] === $caller->deviceId) {
                    continue;
                }
                $schema = RecordSchemas::FIELDS[$table][$column];
                $lost = Fields::fromDatabase($schema, $stored[$column] ?? null);
                if (Fields::canonical($lost) === Fields::canonical(Fields::fromDatabase($schema, $after[$column] ?? null))) {
                    continue;
                }
                $this->conflict($caller, $table, $change->id, $column, $lost, Sql::text($version['change_id']), $revision, $customerId);
            }
        }
        foreach ($columns as $column) {
            $this->sql->run(
                'INSERT INTO field_versions (workspace_id, entity, entity_id, field, revision, change_id) VALUES (?, ?, ?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE revision = VALUES(revision), change_id = VALUES(change_id)',
                [$caller->workspaceId, $table, $change->id, $column, $revision, $change->changeId],
            );
        }
    }

    private function conflict(AuthContext $caller, string $table, string $id, string $field, mixed $lost, string $lostChangeId, int $wonRevision, ?string $customerId): void
    {
        $now = $this->now();
        $this->sql->run(
            'INSERT INTO conflicts (id, workspace_id, customer_id, entity, entity_id, field, lost_value, lost_change_id, won_revision,
                                    created_at, created_by, updated_at, updated_by, revision)
             VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
                Uuid::v7($this->clock->now()),
                $caller->workspaceId,
                $customerId,
                $table,
                $id,
                $field,
                $lost === null ? null : Fields::canonical($lost),
                $lostChangeId,
                $wonRevision,
                $now,
                $caller->userId,
                $now,
                $caller->userId,
                $this->revisions->next($caller->workspaceId),
            ],
        );
    }

    /**
     * @param array<string, string|int|null> $set
     */
    private function update(string $table, string $id, array $set): void
    {
        $this->sql->run(
            "UPDATE {$table} SET " . implode(', ', array_map(static fn(string $c): string => "{$c} = ?", array_keys($set))) . ' WHERE id = ?',
            [...array_values($set), $id],
        );
    }

    /**
     * Turns a database error from writing a change into its rejection: a
     * clash with a live unique value is `duplicate` with the live record's id
     * (D-179), any other broken rule is `invalid`. Other errors are the
     * server's and are rethrown (500).
     *
     * @param array<string, mixed> $values the record as it was to be written
     */
    private function constraint(PDOException $e, string $workspaceId, string $table, string $id, array $values): \Throwable
    {
        $code = $e->errorInfo[1] ?? null;
        $message = $e->getMessage();
        if ($code === self::DUPLICATE_KEY) {
            $key = preg_match("/for key '(?:[^'.]*\\.)?([a-z0-9_]+)'/", $message, $m) === 1 ? $m[1] : '';
            foreach (Entities::LIVE_UNIQUE as $name => $columns) {
                if ($name !== $key) {
                    continue;
                }
                $where = implode(' AND ', array_map(static fn(string $c): string => "{$c} = ?", $columns));
                $bind = array_map(static fn(string $c): ?string => self::scalar($values[$c] ?? null), $columns);
                $row = $this->sql->row(
                    "SELECT id FROM {$table} WHERE workspace_id = ? AND {$where} AND deleted_at IS NULL AND id <> ? LIMIT 1",
                    [$workspaceId, ...$bind, $id],
                );
                if ($row !== null) {
                    return Rejected::duplicate(Sql::text($row['id']), $name);
                }
            }

            return Rejected::invalid('A unique value is taken.');
        }
        if (\in_array($code, self::CONSTRAINT_ERRORS, true)) {
            $rule = preg_match('/\b((?:ck|fk|uq)_[a-z0-9_]+)/', $message, $m) === 1 ? $m[1] : 'a column rule';

            return Rejected::invalid("The record breaks {$rule} ({$code}).");
        }

        return $e;
    }

    /**
     * @param array<string, mixed>|null $stored
     */
    private function status(?array $stored, Change $change): string
    {
        return $stored !== null && self::int($stored['revision']) > ($change->baseRevision ?? 0)
            ? ChangeResult::MERGED
            : ChangeResult::APPLIED;
    }

    private function now(): string
    {
        return Time::toDatabase($this->clock->now());
    }

    /**
     * The synced table of that name, taken from RecordSchemas so that SQL
     * never holds a pushed string.
     */
    private static function table(string $entity): ?string
    {
        foreach (array_keys(RecordSchemas::FIELDS) as $table) {
            if ($table === $entity) {
                return $table;
            }
        }

        return null;
    }

    /**
     * @param array<string, string|int|null> $write
     * @param array<string, mixed>|null $stored
     */
    private static function after(string $column, array $write, ?array $stored): string|int|null
    {
        if (\array_key_exists($column, $write)) {
            return $write[$column];
        }
        $value = $stored[$column] ?? null;

        return \is_string($value) || \is_int($value) ? $value : null;
    }

    private static function scalar(mixed $value): ?string
    {
        if ($value === null || \is_string($value)) {
            return $value;
        }
        if (\is_int($value) || \is_float($value) || \is_bool($value)) {
            return (string) $value;
        }

        throw new RuntimeException('Not a column value.');
    }

    private static function int(mixed $value): int
    {
        if (!is_numeric($value)) {
            throw new RuntimeException('Expected a number column.');
        }

        return (int) $value;
    }

    private static function intOrNull(mixed $value): ?int
    {
        return $value === null ? null : self::int($value);
    }
}
