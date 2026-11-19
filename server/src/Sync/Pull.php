<?php

declare(strict_types=1);

namespace Wio\Sync;

use RuntimeException;
use stdClass;
use Wio\Auth\AuthContext;
use Wio\Database\Sql;

/**
 * GET /sync/pull (plan 006, D-182 to D-184). Reads the synced tables
 * directly by (workspace_id, revision), inside one consistent read-only
 * snapshot: the workspace counter C is read first, and because a writer holds
 * the counter's row lock until it commits (D-52), every revision up to C is
 * committed and visible. The token's scope (ReadScope, D-225) is part of the SQL, so pages stay
 * full and last_revision can move past records the caller may not read.
 *
 * The snapshot holds only under REPEATABLE READ (under READ COMMITTED,
 * MariaDB ignores WITH CONSISTENT SNAPSHOT), so page() sets that level for
 * its transaction instead of trusting the host's default. The row fetch
 * repeats the scope and revision <= C as a second line of defence.
 */
final class Pull
{
    public const int MAX_LIMIT = 500;

    public function __construct(private readonly Sql $sql) {}

    /**
     * @return array{records: list<array<string, mixed>>, has_more: bool, last_revision: int}
     *
     * @throws ResyncRequired
     */
    public function page(AuthContext $caller, int $since, int $limit): array
    {
        $pdo = $this->sql->pdo;
        // Applies to the next transaction only; the session keeps its level.
        $pdo->exec('SET TRANSACTION ISOLATION LEVEL REPEATABLE READ');
        $pdo->exec('START TRANSACTION WITH CONSISTENT SNAPSHOT, READ ONLY');
        try {
            $page = $this->read($caller, $since, $limit);
        } finally {
            $pdo->exec('COMMIT');
        }

        return $page;
    }

    /**
     * @return array{records: list<array<string, mixed>>, has_more: bool, last_revision: int}
     *
     * @throws ResyncRequired
     */
    private function read(AuthContext $caller, int $since, int $limit): array
    {
        $counter = $this->sql->row('SELECT last_revision FROM workspace_counters WHERE workspace_id = ?', [$caller->workspaceId]);
        $top = is_numeric($counter['last_revision'] ?? null) ? (int) $counter['last_revision'] : 0;
        if ($since > $top) {
            throw new ResyncRequired('since is above the workspace counter.');
        }

        $parts = [];
        $values = [];
        foreach (array_keys(RecordSchemas::FIELDS) as $table) {
            $scope = ReadScope::of($caller, $table);
            if ($scope === null) {
                continue;
            }
            [$where, $bind] = $scope;
            $parts[] = "(SELECT '{$table}' AS entity, id, revision FROM {$table} WHERE {$where} AND revision > ? AND revision <= ? ORDER BY revision LIMIT " . ($limit + 1) . ')';
            array_push($values, ...$bind);
            $values[] = $since;
            $values[] = $top;
        }
        $changed = $this->sql->rows(
            'SELECT entity, id, revision FROM (' . implode(' UNION ALL ', $parts) . ') AS changed ORDER BY revision, entity, id LIMIT ' . ($limit + 1),
            $values,
        );
        $hasMore = \count($changed) > $limit;
        $changed = \array_slice($changed, 0, $limit);

        $rows = $this->rows($caller, $changed, $top);
        $records = [];
        foreach ($changed as $item) {
            $entity = Sql::text($item['entity']);
            $id = Sql::text($item['id']);
            $row = $rows[$entity][$id] ?? throw new RuntimeException('A changed record vanished inside the snapshot.');
            $records[] = $this->record($entity, $row);
        }
        $lastReturned = $changed[\count($changed) - 1]['revision'] ?? null;
        $last = $hasMore && is_numeric($lastReturned) ? (int) $lastReturned : $top;

        return ['records' => $records, 'has_more' => $hasMore, 'last_revision' => $last];
    }

    /**
     * The full rows of the changed records, by entity and id, under the same
     * scope and revision <= C as the id list.
     *
     * @param list<array<string, mixed>> $changed
     *
     * @return array<string, array<string, array<string, mixed>>>
     */
    private function rows(AuthContext $caller, array $changed, int $top): array
    {
        $ids = [];
        foreach ($changed as $item) {
            $ids[Sql::text($item['entity'])][] = Sql::text($item['id']);
        }
        $out = [];
        foreach (array_keys(RecordSchemas::FIELDS) as $table) {
            if (!isset($ids[$table])) {
                continue;
            }
            [$where, $bind] = ReadScope::of($caller, $table) ?? throw new \LogicException('A changed record outside the scope.');
            $marks = implode(', ', array_fill(0, \count($ids[$table]), '?'));
            foreach ($this->sql->rows("SELECT * FROM {$table} WHERE {$where} AND revision <= ? AND id IN ({$marks})", [...$bind, $top, ...$ids[$table]]) as $row) {
                $out[$table][Sql::text($row['id'])] = $row;
            }
        }

        return $out;
    }

    /**
     * A pulled record: every field of the entity's record schema, never a
     * server-only column. users.email reaches owners and the user themselves
     * only, because other roles pull no other user row (D-182); M6 keeps that
     * true when it widens their scope.
     *
     * @param array<string, mixed> $row
     *
     * @return array<string, mixed>
     */
    private function record(string $entity, array $row): array
    {
        $fields = new stdClass();
        foreach (RecordSchemas::FIELDS[$entity] as $field => $schema) {
            $fields->{$field} = Fields::fromDatabase($schema, $row[$field] ?? null);
        }

        return [
            'entity' => $entity,
            'id' => $fields->id,
            'revision' => $fields->revision,
            'deleted_at' => $fields->deleted_at,
            'fields' => $fields,
        ];
    }
}
