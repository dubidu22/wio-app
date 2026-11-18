<?php

declare(strict_types=1);

namespace Wio\Tests\Db;

use InvalidArgumentException;
use Wio\Tests\Db\Schema\SchemaTestCase;
use Wio\Tests\Support\DemoWorkspace;

/**
 * The demo workspace (D-78) loads into schema v1 and keeps the data rules of
 * D-79 and D-81. The schema's foreign keys and checks are the main proof: a
 * row that breaks one fails the load.
 */
final class DemoWorkspaceTest extends SchemaTestCase
{
    /** Table number in the demo ids (D-79): 01990000-0000-7000-8000-TTTTNNNNNNNN. */
    private const array TABLE_CODES = [
        'workspaces' => 1, 'users' => 2, 'customers' => 3, 'sites' => 4, 'rooms' => 5, 'openings' => 6,
        'fixtures' => 7, 'labels' => 8, 'property_keys' => 9, 'entries' => 10, 'place_history' => 11,
        'entity_labels' => 12, 'entity_properties' => 13, 'notes' => 14, 'jobs' => 15,
    ];

    /** Where the subject of a polymorphic link or note lives (D-50). */
    private const array SUBJECT_TABLES = [
        'entry' => 'entries', 'room' => 'rooms', 'fixture' => 'fixtures', 'picture' => 'pictures',
        'job' => 'jobs', 'customer' => 'customers',
    ];

    private const array PLACE = ['site_id', 'room_id', 'fixture_id', 'level', 'compartment', 'floor_x_cm', 'floor_y_cm'];

    private DemoWorkspace $demo;

    protected function setUp(): void
    {
        parent::setUp();
        $this->demo = DemoWorkspace::fromFile();
    }

    public function testEveryRowLoadsIntoSchemaV1(): void
    {
        $this->demo->load($this->pdo);

        self::assertSame(1, $this->demo->format);
        self::assertNotSame([], $this->demo->order);
        foreach ($this->demo->order as $table) {
            self::assertNotSame([], $this->demo->rows($table), $table);
            self::assertSame(
                count($this->demo->rows($table)),
                $this->rowCount('SELECT COUNT(*) FROM `' . $table . '`'),
                $table,
            );
        }
        self::assertSame(
            ['01990000-0000-7000-8000-000100000001', '01990000-0000-7000-8000-000100000002'],
            array_keys($this->demo->lastRevisions()),
        );
    }

    public function testRowsListEveryColumnOfTheSchemaExceptDerivedOnes(): void
    {
        $migrations = glob(__DIR__ . '/../../migrations/' . $this->demo->schemaUpTo . '_*.sql');
        self::assertIsArray($migrations);
        self::assertCount(1, $migrations, 'schema_up_to names one migration');

        foreach ($this->demo->order as $table) {
            $columns = array_values(array_diff($this->writableColumnsOf($table), DemoWorkspace::DERIVED));
            sort($columns);
            foreach ($this->demo->rows($table) as $index => $row) {
                $keys = array_keys($row);
                sort($keys);
                self::assertSame($columns, $keys, sprintf('%s row %d', $table, $index));
            }
        }
    }

    public function testIdsAreReadableV7IdsWithTheirTableNumber(): void
    {
        $seen = [];
        foreach ($this->demo->order as $table) {
            self::assertArrayHasKey($table, self::TABLE_CODES);
            foreach ($this->demo->rows($table) as $index => $row) {
                $id = $this->string($row, 'id');
                $pattern = sprintf('/^01990000-0000-7000-8000-%04x[0-9a-f]{8}$/', self::TABLE_CODES[$table]);
                self::assertMatchesRegularExpression($pattern, $id, sprintf('%s row %d', $table, $index));
                self::assertArrayNotHasKey($id, $seen, 'ids are unique across tables');
                $seen[$id] = true;
            }
        }
    }

    public function testRevisionsAreUniquePerWorkspaceAndTheCounterHoldsTheHighest(): void
    {
        $byWorkspace = [];
        foreach ($this->demo->order as $table) {
            foreach ($this->demo->rows($table) as $row) {
                $workspace = $this->string($row, $table === 'workspaces' ? 'id' : 'workspace_id');
                $revision = $row['revision'] ?? null;
                self::assertIsInt($revision);
                self::assertGreaterThanOrEqual(1, $revision);
                $byWorkspace[$workspace][] = $revision;
                self::assertGreaterThanOrEqual($this->string($row, 'created_at'), $this->string($row, 'updated_at'));
            }
        }
        foreach ($byWorkspace as $workspace => $revisions) {
            self::assertSame(count($revisions), count(array_unique($revisions)), $workspace);
        }

        $this->demo->load($this->pdo);
        $counters = [];
        foreach ($this->rowsOf('SELECT workspace_id, last_revision FROM workspace_counters ORDER BY workspace_id') as $row) {
            $last = $row['last_revision'] ?? null;
            self::assertTrue(is_int($last) || is_string($last));
            $counters[$this->string($row, 'workspace_id')] = (int) $last;
        }
        $expected = array_map(static fn(array $revisions): int => max($revisions), $byWorkspace);
        ksort($expected);
        self::assertSame($expected, $counters);
    }

    public function testOnlyInventedContactData(): void
    {
        $emails = [];
        foreach ($this->demo->rows('users') as $row) {
            $emails[] = $row['email'] ?? null;
        }
        foreach ($this->demo->rows('customers') as $row) {
            $contact = $row['contact'] ?? null;
            self::assertIsArray($contact);
            self::assertSame(['email'], array_keys($contact), 'contact holds an e-mail only, never a phone number');
            $emails[] = $contact['email'];
        }
        foreach (array_filter($emails, static fn(mixed $email): bool => $email !== null) as $email) {
            self::assertIsString($email);
            self::assertMatchesRegularExpression('/^[a-z0-9.]+@example\.org$/', $email);
        }

        foreach ($this->demo->rows('sites') as $row) {
            $address = $this->string($row, 'address');
            self::assertMatchesRegularExpression('/\b00000\b/', $address, 'postal code 00000 is never real');
            self::assertSame(1, preg_match_all('/\b\d{5}\b/', $address), $address);
        }
    }

    public function testNoStringLooksLikeRealContactData(): void
    {
        foreach ($this->demo->order as $table) {
            foreach ($this->demo->rows($table) as $index => $row) {
                $strings = [];
                array_walk_recursive($row, static function (mixed $value) use (&$strings): void {
                    if (is_string($value)) {
                        $strings[] = $value;
                    }
                });
                foreach ($strings as $value) {
                    $what = sprintf('%s row %d: "%s"', $table, $index, $value);
                    if (str_contains($value, '@')) {
                        self::assertMatchesRegularExpression('/^[a-z0-9.]+@example\.org$/', $value, $what);
                    }
                    if (preg_match('/^\d{4}-\d{2}-\d{2}(T[0-9:.]+Z)?$/', $value) !== 1
                        && preg_match('/^[0-9a-f]{8}(-[0-9a-f]{4}){3}-[0-9a-f]{12}$/', $value) !== 1) {
                        self::assertDoesNotMatchRegularExpression('/\+?\d[\d \/()-]{5,}\d/', $value, $what . ' looks like a phone number');
                    }
                }
            }
        }
    }

    public function testEveryEntrysPlaceMatchesItsNewestHistoryRow(): void
    {
        $history = [];
        foreach ($this->demo->rows('place_history') as $row) {
            $history[$this->string($row, 'entry_id')][] = $row;
        }

        foreach ($this->demo->rows('entries') as $entry) {
            $rows = $history[$this->string($entry, 'id')] ?? [];
            usort($rows, fn(array $a, array $b): int => $this->string($a, 'moved_at') <=> $this->string($b, 'moved_at'));
            if ($rows !== []) {
                $what = $this->string($entry, 'id');
                $first = $this->string($rows[0], 'moved_at');
                $newest = $this->string($rows[count($rows) - 1], 'moved_at');
                self::assertGreaterThanOrEqual($this->string($entry, 'created_at'), $first, $what . ': moved before it existed');
                self::assertLessThanOrEqual($this->string($entry, 'updated_at'), $newest, $what . ': moved after its last update');
            }
            $previous = array_fill_keys(self::PLACE, null);
            foreach ($rows as $row) {
                self::assertSame($entry['customer_id'], $row['customer_id']);
                self::assertSame($previous, $this->place($row, 'from_'), 'each move starts where the last one ended');
                $previous = $this->place($row, 'to_');
            }
            self::assertSame($previous, $this->place($entry, ''), 'the entry stands where its history ends');
        }
    }

    public function testLinksAndNotesPointAtSubjectsOfTheSameWorkspaceAndCustomer(): void
    {
        $byId = [];
        foreach ($this->demo->order as $table) {
            foreach ($this->demo->rows($table) as $row) {
                $byId[$this->string($row, 'id')] = [$table, $row];
            }
        }

        foreach (['entity_labels' => 'entity', 'entity_properties' => 'entity', 'notes' => 'subject'] as $table => $prefix) {
            foreach ($this->demo->rows($table) as $index => $row) {
                $what = sprintf('%s row %d', $table, $index);
                $type = $this->string($row, $prefix . '_type');
                [$subjectTable, $subject] = $byId[$this->string($row, $prefix . '_id')] ?? [null, []];
                self::assertSame(self::SUBJECT_TABLES[$type] ?? null, $subjectTable, $what);
                self::assertSame($subject['workspace_id'] ?? null, $row['workspace_id'], $what);
                $subjectCustomer = $subjectTable === 'customers' ? $subject['id'] : $subject['customer_id'] ?? null;
                self::assertSame($subjectCustomer, $row['customer_id'], $what);
            }
        }
    }

    public function testLoadingTwiceFailsInsteadOfMerging(): void
    {
        $this->demo->load($this->pdo);

        $this->assertRejected(self::DUPLICATE, fn() => $this->demo->load($this->pdo));
    }

    public function testUnknownTableIsRejectedBeforeAnySql(): void
    {
        $demo = DemoWorkspace::fromJson('{"format": 1, "schema_up_to": "0007", "tables": ['
            . '{"table": "secrets", "rows": [{"id": "x"}]}]}');

        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Table "secrets" is not in the database schema.');
        $demo->load($this->pdo);
    }

    public function testUnknownOrDerivedColumnIsRejectedBeforeAnySql(): void
    {
        foreach (['`id`; DROP TABLE labels; --', 'name_key', 'alive', 'colour'] as $column) {
            $demo = DemoWorkspace::fromJson((string) json_encode([
                'format' => 1,
                'schema_up_to' => '0007',
                'tables' => [['table' => 'labels', 'rows' => [[$column => 'x']]]],
            ]));
            try {
                $demo->load($this->pdo);
                self::fail(sprintf('Column "%s" was accepted.', $column));
            } catch (InvalidArgumentException $e) {
                self::assertStringContainsString('is unknown or derived', $e->getMessage());
            }
        }
        self::assertSame(0, $this->rowCount('SELECT COUNT(*) FROM labels'));
    }

    public function testFileTimesBecomeDatabaseTimes(): void
    {
        self::assertSame('2026-11-02 08:01:00.000', DemoWorkspace::databaseTime('2026-11-02T08:01:00.000Z'));

        $this->expectException(InvalidArgumentException::class);
        DemoWorkspace::databaseTime('2026-11-02 08:01:00');
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, mixed>
     */
    private function place(array $row, string $prefix): array
    {
        $place = [];
        foreach (self::PLACE as $field) {
            $place[$field] = $row[$prefix . $field] ?? null;
        }

        return $place;
    }

    /**
     * @param array<string, mixed> $row
     */
    private function string(array $row, string $column): string
    {
        $value = $row[$column] ?? null;
        self::assertIsString($value, $column);

        return $value;
    }

    /**
     * @return list<string>
     */
    private function writableColumnsOf(string $table): array
    {
        $types = DemoWorkspace::columnTypes($this->pdo)[$table] ?? [];
        self::assertNotSame([], $types, $table);

        return array_keys(array_filter($types, static fn(string $type): bool => $type !== DemoWorkspace::GENERATED));
    }

    private function rowCount(string $sql): int
    {
        $statement = $this->pdo->query($sql);
        self::assertNotFalse($statement);
        $value = $statement->fetchColumn();
        self::assertNotFalse($value);

        return (int) $value;
    }
}
