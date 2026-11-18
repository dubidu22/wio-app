<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

use PHPUnit\Framework\TestCase;
use Wio\Tests\Api\Contract;

/**
 * The record schemas of the contract follow schema v1 (D-95): the same
 * columns, the same nullability and a matching type, compared with the
 * reviewed database snapshot that SchemaSnapshotTest keeps equal to the
 * migrations.
 */
final class ContractSchemaTest extends TestCase
{
    private const string SNAPSHOT = __DIR__ . '/../../Db/Schema/schema-snapshot.json';

    /** JSON columns whose value may be any JSON, null included. */
    private const array ANY_JSON = ['conflicts.lost_value'];

    public function testThereIsOneRecordSchemaPerSyncedTable(): void
    {
        $synced = array_diff(array_keys($this->snapshot()), RecordSchemas::SERVER_TABLES);
        sort($synced);
        $mapped = array_keys(RecordSchemas::BY_TABLE);
        sort($mapped);

        self::assertSame($synced, $mapped);
        foreach (RecordSchemas::BY_TABLE as $schema) {
            self::assertArrayHasKey($schema, Contract::schemas(), "Record schema {$schema} is missing");
        }
    }

    public function testTheEntityNameListsEverySyncedTable(): void
    {
        $description = Contract::text(Contract::schema('EntityName')['description'] ?? null);
        foreach (array_keys(RecordSchemas::BY_TABLE) as $table) {
            self::assertMatchesRegularExpression('/\b' . $table . '\b/', $description, "EntityName does not document {$table}");
        }
    }

    public function testEachRecordSchemaMatchesItsTable(): void
    {
        $snapshot = $this->snapshot();
        foreach (RecordSchemas::BY_TABLE as $table => $name) {
            $schema = Contract::schema($name);
            $properties = Contract::map($schema['properties'] ?? null);
            $columns = $this->columns($snapshot[$table] ?? []);
            $expected = array_values(array_diff(array_keys($columns), RecordSchemas::SERVER_COLUMNS));

            self::assertSame($expected, array_keys($properties), "{$name}: properties must equal the columns of {$table}, in order, without server-only columns");
            self::assertSame($expected, $schema['required'] ?? null, "{$name}: a pulled record carries every field");

            foreach ($expected as $column) {
                $this->assertColumn("{$table}.{$column}", $columns[$column], Contract::map($properties[$column]));
            }
        }
    }

    public function testEnumsEqualTheDatabaseChecks(): void
    {
        $snapshot = $this->snapshot();
        $found = 0;
        foreach (RecordSchemas::BY_TABLE as $table => $name) {
            $properties = Contract::map(Contract::schema($name)['properties'] ?? null);
            foreach ((array) (Contract::map($snapshot[$table] ?? null)['checks'] ?? []) as $check) {
                if (!\is_string($check) || preg_match("/`(\\w+)` in \\(([^)]*)\\)/", $check, $m) !== 1) {
                    continue;
                }
                $values = array_map(static fn(string $v): string => trim($v, " '"), explode(',', $m[2]));
                $property = Contract::map($properties[$m[1]] ?? null);
                self::assertSame($values, $property['enum'] ?? null, "{$table}.{$m[1]}: enum must equal the database CHECK");
                ++$found;
            }
        }
        self::assertGreaterThanOrEqual(8, $found, 'The snapshot CHECK lists were not found');
    }

    /**
     * @param array<string, mixed> $property
     */
    private function assertColumn(string $where, string $definition, array $property): void
    {
        $type = explode(' ', $definition)[1] ?? '';
        $column = explode('.', $where, 2)[1] ?? '';
        $nullable = !str_contains($definition, 'NOT NULL');

        if (\in_array($where, self::ANY_JSON, true)) {
            self::assertArrayNotHasKey('type', $property, "{$where}: any JSON has no type");

            return;
        }

        self::assertSame($nullable, ($property['nullable'] ?? false) === true, "{$where}: nullability differs from the database");
        self::assertSame(
            \in_array($column, RecordSchemas::SERVER_SET, true),
            ($property['readOnly'] ?? false) === true,
            "{$where}: exactly the server-set fields are readOnly",
        );

        $family = match (true) {
            str_starts_with($type, 'char(36)') => ['string', 'uuid'],
            str_starts_with($type, 'char(64)') => ['string', null],
            str_starts_with($type, 'varchar'), $type === 'text' => ['string', null],
            $type === 'longtext' => [null, null],
            str_starts_with($type, 'bigint') => ['integer', 'int64'],
            str_starts_with($type, 'int'), str_starts_with($type, 'smallint'), str_starts_with($type, 'tinyint') => ['integer', 'int32'],
            str_starts_with($type, 'datetime') => ['string', 'date-time'],
            $type === 'date' => ['string', 'date'],
            str_starts_with($type, 'decimal') => ['string', null],
            default => self::fail("{$where}: no contract type for {$type}"),
        };

        if ($family[0] === null) {
            self::assertContains($property['type'] ?? null, ['object', 'array'], "{$where}: a JSON column is an object or an array");

            return;
        }
        self::assertSame($family[0], $property['type'] ?? null, "{$where}: type");
        self::assertSame($family[1], $property['format'] ?? null, "{$where}: format");

        if (preg_match('/^varchar\((\d+)\)$/', $type, $m) === 1 && !\array_key_exists('enum', $property)) {
            self::assertSame((int) $m[1], $property['maxLength'] ?? null, "{$where}: maxLength");
        }
        if (str_contains($definition, 'unsigned') && $family[0] === 'integer') {
            self::assertGreaterThanOrEqual(0, $property['minimum'] ?? -1, "{$where}: unsigned needs a minimum");
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function snapshot(): array
    {
        $decoded = json_decode((string) file_get_contents(self::SNAPSHOT), true, flags: JSON_THROW_ON_ERROR);

        return Contract::map($decoded);
    }

    /**
     * @return array<string, string> column => definition
     */
    private function columns(mixed $table): array
    {
        $columns = [];
        foreach ((array) (Contract::map($table)['columns'] ?? []) as $definition) {
            $definition = Contract::text($definition);
            $columns[explode(' ', $definition)[0]] = $definition;
        }

        return $columns;
    }
}
