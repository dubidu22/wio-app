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
 * committed and visible. The token's scope is part of the SQL, so pages stay
 * full and last_revision can move past records the caller may not read.
 */
final class Pull
{
    public const int MAX_LIMIT = 500;

    /** Every synced table but these has customer_id and is read by a customer for their own customer only. */
    private const array CUSTOMER_READS_ALL = ['labels', 'property_keys'];

    public function __construct(private readonly Sql $sql) {}

    /**
     * @return array{records: list<array<string, mixed>>, has_more: bool, last_revision: int}
     *
     * @throws ResyncRequired
     */
    public function page(AuthContext $caller, int $since, int $limit): array
    {
        $pdo = $this->sql->pdo;
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
            $scope = $this->scope($caller, $table);
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

        $rows = $this->rows($caller, $changed);
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
     * The rows a caller may read from one table (D-182), as SQL and values;
     * null when the caller reads nothing from it.
     *
     * @return array{string, list<string>}|null
     */
    private function scope(AuthContext $caller, string $table): ?array
    {
        $workspace = $table === 'workspaces' ? 'id = ?' : 'workspace_id = ?';
        if ($caller->role === 'owner') {
            return [$workspace, [$caller->workspaceId]];
        }
        if ($table === 'workspaces') {
            return [$workspace, [$caller->workspaceId]];
        }
        if ($table === 'users') {
            return ['workspace_id = ? AND id = ?', [$caller->workspaceId, $caller->userId]];
        }
        if ($caller->role !== 'customer' || $caller->customerId === null || $table === 'conflicts') {
            return null;
        }
        if (\in_array($table, self::CUSTOMER_READS_ALL, true)) {
            return [$workspace, [$caller->workspaceId]];
        }
        if ($table === 'customers') {
            return ['workspace_id = ? AND id = ?', [$caller->workspaceId, $caller->customerId]];
        }
        if (!isset(RecordSchemas::FIELDS[$table]['customer_id'])) {
            return null;
        }

        return ['workspace_id = ? AND customer_id = ?', [$caller->workspaceId, $caller->customerId]];
    }

    /**
     * The full rows of the changed records, by entity and id.
     *
     * @param list<array<string, mixed>> $changed
     *
     * @return array<string, array<string, array<string, mixed>>>
     */
    private function rows(AuthContext $caller, array $changed): array
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
            $workspace = $table === 'workspaces' ? 'id = ?' : 'workspace_id = ?';
            $marks = implode(', ', array_fill(0, \count($ids[$table]), '?'));
            foreach ($this->sql->rows("SELECT * FROM {$table} WHERE {$workspace} AND id IN ({$marks})", [$caller->workspaceId, ...$ids[$table]]) as $row) {
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
