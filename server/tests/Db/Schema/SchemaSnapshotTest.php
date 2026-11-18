<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

/**
 * The migrated schema, read from information_schema, must equal the reviewed
 * snapshot in schema-snapshot.json. A schema change therefore shows up in
 * review as a few changed lines of that file.
 *
 * To update it after an intended change, run once with
 * WIO_UPDATE_SCHEMA_SNAPSHOT=1; the test writes the file and fails, so a
 * stale snapshot is never accepted silently.
 */
final class SchemaSnapshotTest extends SchemaTestCase
{
    private const string FILE = __DIR__ . '/schema-snapshot.json';

    public function testTheSchemaMatchesTheReviewedSnapshot(): void
    {
        $actual = $this->snapshot();

        if (getenv('WIO_UPDATE_SCHEMA_SNAPSHOT') === '1') {
            file_put_contents(self::FILE, $actual);
            self::fail('Snapshot written to ' . self::FILE . '; review it and run again without WIO_UPDATE_SCHEMA_SNAPSHOT.');
        }

        self::assertFileExists(self::FILE);
        self::assertSame(file_get_contents(self::FILE), $actual);
    }

    private function snapshot(): string
    {
        $tables = [];
        foreach ($this->strings("SELECT TABLE_NAME FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE()") as $table) {
            $quoted = $this->pdo->quote($table);
            $tables[$table] = [
                'columns' => $this->strings(
                    "SELECT CONCAT_WS(' ', COLUMN_NAME, COLUMN_TYPE, CHARACTER_SET_NAME, COLLATION_NAME,
                            IF(IS_NULLABLE = 'YES', 'NULL', 'NOT NULL'),
                            IF(COLUMN_DEFAULT IS NULL OR COLUMN_DEFAULT = 'NULL', NULL, CONCAT('DEFAULT ', COLUMN_DEFAULT)),
                            IF(GENERATION_EXPRESSION IS NULL, NULL, CONCAT('AS (', GENERATION_EXPRESSION, ') ', EXTRA)))
                     FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = {$quoted}
                     ORDER BY ORDINAL_POSITION",
                ),
                'indexes' => $this->sorted(
                    "SELECT CONCAT(INDEX_NAME, IF(NON_UNIQUE = 0, ' UNIQUE', ''), ' (',
                            GROUP_CONCAT(COLUMN_NAME ORDER BY SEQ_IN_INDEX SEPARATOR ', '), ')')
                     FROM information_schema.STATISTICS WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = {$quoted}
                     GROUP BY INDEX_NAME, NON_UNIQUE",
                ),
                'foreign_keys' => $this->sorted(
                    "SELECT CONCAT(k.CONSTRAINT_NAME, ' (', GROUP_CONCAT(k.COLUMN_NAME ORDER BY k.ORDINAL_POSITION SEPARATOR ', '),
                            ') -> ', k.REFERENCED_TABLE_NAME, ' (',
                            GROUP_CONCAT(k.REFERENCED_COLUMN_NAME ORDER BY k.ORDINAL_POSITION SEPARATOR ', '),
                            ') ON DELETE ', r.DELETE_RULE, ' ON UPDATE ', r.UPDATE_RULE)
                     FROM information_schema.KEY_COLUMN_USAGE k
                     JOIN information_schema.REFERENTIAL_CONSTRAINTS r
                       ON r.CONSTRAINT_SCHEMA = k.CONSTRAINT_SCHEMA AND r.CONSTRAINT_NAME = k.CONSTRAINT_NAME
                      AND r.TABLE_NAME = k.TABLE_NAME
                     WHERE k.TABLE_SCHEMA = DATABASE() AND k.TABLE_NAME = {$quoted} AND k.REFERENCED_TABLE_NAME IS NOT NULL
                     GROUP BY k.CONSTRAINT_NAME, k.REFERENCED_TABLE_NAME, r.DELETE_RULE, r.UPDATE_RULE",
                ),
                'checks' => $this->sorted(
                    "SELECT CONCAT(CONSTRAINT_NAME, ': ', CHECK_CLAUSE) FROM information_schema.CHECK_CONSTRAINTS
                     WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = {$quoted}",
                ),
            ];
        }
        ksort($tables, SORT_STRING);

        return json_encode($tables, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR) . "\n";
    }

    /**
     * @return list<string>
     */
    private function sorted(string $sql): array
    {
        $values = $this->strings($sql);
        sort($values, SORT_STRING);

        return $values;
    }

    /**
     * @return list<string>
     */
    private function strings(string $sql): array
    {
        return array_map(
            static fn(array $row): string => is_scalar($value = reset($row)) ? (string) $value : '',
            $this->rowsOf($sql),
        );
    }
}
