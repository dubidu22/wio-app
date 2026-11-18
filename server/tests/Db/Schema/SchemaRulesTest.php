<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

/**
 * The patterns every table must follow, read from information_schema, so a
 * new table that forgets one fails here (D-47, D-48, D-49, D-52;
 * server/migrations/README.md).
 */
final class SchemaRulesTest extends SchemaTestCase
{
    private const array NOT_SYNCED = ['schema_migrations', 'workspace_counters'];
    /** Users are actors, not records a customer owns, so links to them need no customer key. */
    private const array ACTOR_TABLES = ['users'];

    private const array COMMON_COLUMNS = [
        'id' => 'char(36) ascii ascii_bin NO',
        'created_at' => 'datetime(3) NO',
        'created_by' => 'char(36) ascii ascii_bin YES',
        'updated_at' => 'datetime(3) NO',
        'updated_by' => 'char(36) ascii ascii_bin YES',
        'revision' => 'bigint(20) unsigned NO',
        'deleted_at' => 'datetime(3) YES',
    ];

    public function testEverySyncedTableHasTheCommonFields(): void
    {
        foreach ($this->syncedTables() as $table) {
            $columns = $this->columns($table);
            foreach (self::COMMON_COLUMNS as $name => $definition) {
                self::assertSame($definition, $columns[$name] ?? null, "{$table}.{$name}");
            }
            if ($table !== 'workspaces') {
                self::assertSame('char(36) ascii ascii_bin NO', $columns['workspace_id'] ?? null, "{$table}.workspace_id");
            }
        }
    }

    public function testEverySyncedTableIsIndexedByWorkspaceAndRevision(): void
    {
        foreach ($this->syncedTables() as $table) {
            $first = $table === 'workspaces' ? 'id' : 'workspace_id';
            self::assertContains(
                "{$first},revision",
                $this->indexColumns($table),
                "{$table} needs KEY ix_{$table}_revision ({$first}, revision)",
            );
        }
    }

    public function testEverySyncedTableChecksItsIdPattern(): void
    {
        $checks = $this->column(
            "SELECT TABLE_NAME FROM information_schema.CHECK_CONSTRAINTS
             WHERE CONSTRAINT_SCHEMA = DATABASE() AND CONSTRAINT_NAME = CONCAT('ck_', TABLE_NAME, '_id')",
        );
        foreach ($this->syncedTables() as $table) {
            self::assertContains($table, $checks, "{$table} needs CONSTRAINT ck_{$table}_id");
        }
    }

    public function testEveryTableBelongsToAWorkspace(): void
    {
        foreach ($this->tables() as $table) {
            if (in_array($table, ['schema_migrations', 'workspaces'], true)) {
                continue;
            }
            self::assertContains(
                'workspace_id -> workspaces.id',
                $this->foreignKeys($table),
                "{$table} needs a foreign key from workspace_id to workspaces",
            );
        }
    }

    public function testEveryForeignKeyCarriesTheWorkspace(): void
    {
        foreach ($this->tables() as $table) {
            foreach ($this->foreignKeys($table) as $key) {
                if ($key === 'workspace_id -> workspaces.id') {
                    continue;
                }
                self::assertStringStartsWith('workspace_id,', $key, "{$table}: {$key}");
                self::assertStringContainsString('.workspace_id,', $key, "{$table}: {$key}");
            }
        }
    }

    public function testCustomerScopedTablesCarryTheCustomerIntoEveryParentThatHasOne(): void
    {
        $withCustomer = $this->column(
            "SELECT TABLE_NAME FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME = 'customer_id'",
        );
        $nullable = $this->column(
            "SELECT TABLE_NAME FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME = 'customer_id' AND IS_NULLABLE = 'YES'",
        );
        foreach ($withCustomer as $table) {
            $keys = $this->foreignKeys($table);
            self::assertContains('workspace_id,customer_id -> customers.workspace_id,id', $keys, $table);
            foreach ($keys as $key) {
                // Only direct links (workspace_id, x) -> parent (workspace_id, id). A chained
                // link such as (workspace_id, site_id, room_id) -> rooms (workspace_id, site_id, id)
                // inherits the customer from the direct link it is chained to.
                if (preg_match('/^workspace_id,([a-z_]+) -> ([a-z_]+)\.workspace_id,id$/', $key, $m) !== 1) {
                    continue;
                }
                [$column, $parent] = [$m[1], $m[2]];
                if ($column === 'customer_id' || in_array($parent, self::ACTOR_TABLES, true) || !in_array($parent, $withCustomer, true)) {
                    continue;
                }
                $expected = "workspace_id,customer_id,{$column} -> {$parent}.workspace_id,customer_id,id";
                self::assertContains($expected, $keys, "{$table}.{$column} points at {$parent}, which has a customer");
                if (in_array($table, $nullable, true) && in_array($parent, $nullable, true)) {
                    $flagged = "workspace_id,no_customer,{$column} -> {$parent}.workspace_id,no_customer,id";
                    self::assertContains($flagged, $keys, "{$table}.{$column}: a null customer must not hang under {$parent}");
                }
            }
        }
    }

    public function testAChildOfACustomerScopedParentHasACustomer(): void
    {
        $withCustomer = $this->column(
            "SELECT TABLE_NAME FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND COLUMN_NAME = 'customer_id'",
        );
        foreach ($this->tables() as $table) {
            foreach ($this->foreignKeys($table) as $key) {
                if (preg_match('/^workspace_id,[a-z_]+ -> ([a-z_]+)\.workspace_id,id$/', $key, $m) !== 1) {
                    continue;
                }
                $parent = $m[1];
                if (in_array($parent, self::ACTOR_TABLES, true) || !in_array($parent, $withCustomer, true)) {
                    continue;
                }
                self::assertContains($table, $withCustomer, "{$table} links to {$parent}, which has a customer, so it needs customer_id");
            }
        }
    }

    public function testEveryForeignKeyRestrictsDeletesAndUpdates(): void
    {
        $rules = $this->column(
            "SELECT DISTINCT CONCAT(DELETE_RULE, '/', UPDATE_RULE) FROM information_schema.REFERENTIAL_CONSTRAINTS
             WHERE CONSTRAINT_SCHEMA = DATABASE()",
        );

        self::assertSame(['RESTRICT/RESTRICT'], $rules);
    }

    public function testNoTriggersRoutinesOrEvents(): void
    {
        foreach (['TRIGGERS' => 'TRIGGER_SCHEMA', 'ROUTINES' => 'ROUTINE_SCHEMA', 'EVENTS' => 'EVENT_SCHEMA'] as $view => $schema) {
            self::assertSame(
                ['0'],
                $this->column("SELECT COUNT(*) FROM information_schema.{$view} WHERE {$schema} = DATABASE()"),
                "D-54: no {$view}",
            );
        }
    }

    /**
     * @return list<string>
     */
    private function tables(): array
    {
        return $this->column(
            "SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() ORDER BY TABLE_NAME",
        );
    }

    /**
     * @return list<string>
     */
    private function syncedTables(): array
    {
        return array_values(array_diff($this->tables(), self::NOT_SYNCED));
    }

    /**
     * @return array<string, string> column => "type [charset collation] nullable"
     */
    private function columns(string $table): array
    {
        $columns = [];
        foreach ($this->rowsOf(
            "SELECT COLUMN_NAME AS n, CONCAT_WS(' ', COLUMN_TYPE, CHARACTER_SET_NAME, COLLATION_NAME, IS_NULLABLE) AS d
             FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = " . $this->pdo->quote($table),
        ) as $row) {
            $columns[is_string($row['n']) ? $row['n'] : ''] = is_string($row['d']) ? $row['d'] : '';
        }

        return $columns;
    }

    /**
     * @return list<string> "a,b" per index
     */
    private function indexColumns(string $table): array
    {
        return $this->column(
            'SELECT GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX) FROM information_schema.STATISTICS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ' . $this->pdo->quote($table) . ' GROUP BY INDEX_NAME',
        );
    }

    /**
     * @return list<string> "a,b -> parent.c,d" per foreign key
     */
    private function foreignKeys(string $table): array
    {
        return $this->column(
            "SELECT CONCAT(GROUP_CONCAT(COLUMN_NAME ORDER BY ORDINAL_POSITION), ' -> ', REFERENCED_TABLE_NAME, '.',
                    GROUP_CONCAT(REFERENCED_COLUMN_NAME ORDER BY ORDINAL_POSITION))
             FROM information_schema.KEY_COLUMN_USAGE
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = " . $this->pdo->quote($table) . '
               AND REFERENCED_TABLE_NAME IS NOT NULL
             GROUP BY CONSTRAINT_NAME, REFERENCED_TABLE_NAME',
        );
    }

    /**
     * @return list<string>
     */
    private function column(string $sql): array
    {
        return array_map(
            static fn(array $row): string => is_scalar($value = reset($row)) ? (string) $value : '',
            $this->rowsOf($sql),
        );
    }
}
