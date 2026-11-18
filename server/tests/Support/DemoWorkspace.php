<?php

declare(strict_types=1);

namespace Wio\Tests\Support;

use InvalidArgumentException;
use JsonException;
use PDO;
use RuntimeException;
use Wio\Schema\NameKey;

/**
 * The invented demo workspace of tools/demo/demo-workspace.json (D-78), read
 * and loaded into a migrated database for tests.
 *
 * The file holds the tables in insert order with the column names of the
 * migrations. Columns the server derives are not in the file: `name_key` and
 * `email_key` the loader makes with the server's own NameKey (D-51); generated
 * columns (`alive`, `no_customer`, ...) the database makes; and the loader
 * adds one `workspace_counters` row per workspace set to its highest revision
 * (D-52).
 *
 * Every table and column name is checked against information_schema before it
 * is written into SQL, so a broken file fails with a message, never with
 * SQL built from its text.
 */
final class DemoWorkspace
{
    public const string FILE = __DIR__ . '/../../../tools/demo/demo-workspace.json';

    /** Columns the loader derives; the file must not hold them, nor any generated column. */
    public const array DERIVED = ['name_key', 'email_key'];

    private const string FILE_TIME = '/^(\d{4}-\d{2}-\d{2})T(\d{2}:\d{2}:\d{2}\.\d{3})Z$/';

    private const string IDENTIFIER = '/^[a-z][a-z0-9_]*$/';

    /** Stands in for the data type of a generated column in columnTypes(). */
    public const string GENERATED = 'generated';

    /**
     * @param list<string> $order table names in insert order
     * @param array<string, list<array<string, mixed>>> $rows rows per table
     */
    private function __construct(
        public readonly int $format,
        public readonly string $schemaUpTo,
        public readonly array $order,
        private readonly array $rows,
    ) {}

    public static function fromFile(string $path = self::FILE): self
    {
        $json = file_get_contents($path);
        if ($json === false) {
            throw new InvalidArgumentException(sprintf('Cannot read %s.', $path));
        }

        return self::fromJson($json);
    }

    public static function fromJson(string $json): self
    {
        try {
            $data = json_decode($json, true, 64, JSON_THROW_ON_ERROR);
        } catch (JsonException $e) {
            throw new InvalidArgumentException('The demo file is not valid JSON: ' . $e->getMessage(), 0, $e);
        }
        if (!is_array($data) || !is_int($data['format'] ?? null) || !is_string($data['schema_up_to'] ?? null)
            || !is_array($data['tables'] ?? null) || !array_is_list($data['tables'])) {
            throw new InvalidArgumentException('The demo file needs "format", "schema_up_to" and a "tables" list.');
        }

        $order = [];
        $rows = [];
        foreach ($data['tables'] as $index => $block) {
            if (!is_array($block) || !is_string($block['table'] ?? null) || !is_array($block['rows'] ?? null)
                || !array_is_list($block['rows'])) {
                throw new InvalidArgumentException(sprintf('Table block %d needs "table" and a "rows" list.', $index));
            }
            $table = $block['table'];
            if (preg_match(self::IDENTIFIER, $table) !== 1 || isset($rows[$table])) {
                throw new InvalidArgumentException(sprintf('Table name "%s" is invalid or repeated.', $table));
            }
            $tableRows = [];
            foreach ($block['rows'] as $rowIndex => $row) {
                if (!is_array($row) || $row === [] || array_is_list($row)) {
                    throw new InvalidArgumentException(sprintf('Row %d of %s is not an object.', $rowIndex, $table));
                }
                $clean = [];
                foreach ($row as $column => $value) {
                    $clean[(string) $column] = $value;
                }
                $tableRows[] = $clean;
            }
            $order[] = $table;
            $rows[$table] = $tableRows;
        }

        return new self($data['format'], $data['schema_up_to'], $order, $rows);
    }

    /**
     * @return list<array<string, mixed>>
     */
    public function rows(string $table): array
    {
        return $this->rows[$table] ?? [];
    }

    /**
     * Highest revision per workspace id, over every row of the file.
     *
     * @return array<string, int>
     */
    public function lastRevisions(): array
    {
        $last = [];
        foreach ($this->order as $table) {
            foreach ($this->rows[$table] as $row) {
                $workspace = $table === 'workspaces' ? $row['id'] : $row['workspace_id'] ?? null;
                $revision = $row['revision'] ?? null;
                if (is_string($workspace) && is_int($revision)) {
                    $last[$workspace] = max($last[$workspace] ?? 0, $revision);
                }
            }
        }
        ksort($last);

        return $last;
    }

    /**
     * Inserts every row, then the workspace counters. Runs inside the caller's
     * transaction, if any; it never merges with rows that already exist.
     */
    public function load(PDO $pdo): void
    {
        $schema = self::columnTypes($pdo);
        foreach ($this->order as $table) {
            $types = $schema[$table] ?? throw new InvalidArgumentException(
                sprintf('Table "%s" is not in the database schema.', $table),
            );
            foreach ($this->rows[$table] as $index => $row) {
                $values = [];
                foreach ($row as $column => $value) {
                    $type = $types[$column] ?? null;
                    if ($type === null || $type === self::GENERATED || in_array($column, self::DERIVED, true)
                        || preg_match(self::IDENTIFIER, $column) !== 1) {
                        throw new InvalidArgumentException(
                            sprintf('Row %d of %s: column "%s" is unknown or derived.', $index, $table, $column),
                        );
                    }
                    $values[$column] = self::toDatabase($value, $type, $table, $column);
                }
                $values += self::derivedKeys($table, $row);
                self::insert($pdo, $table, $values);
            }
        }
        foreach ($this->lastRevisions() as $workspace => $revision) {
            self::insert($pdo, 'workspace_counters', ['workspace_id' => $workspace, 'last_revision' => $revision]);
        }
    }

    /**
     * Converts a file time ("2026-11-02T08:01:00.000Z") to DATETIME(3) text.
     */
    public static function databaseTime(string $fileTime): string
    {
        if (preg_match(self::FILE_TIME, $fileTime, $m) !== 1) {
            throw new InvalidArgumentException(sprintf('"%s" is not an ISO-8601 UTC time with milliseconds.', $fileTime));
        }

        return $m[1] . ' ' . $m[2];
    }

    /**
     * @param array<string, mixed> $row
     * @return array<string, string>
     */
    private static function derivedKeys(string $table, array $row): array
    {
        $name = $row['name'] ?? null;
        $email = $row['email'] ?? null;

        return match ($table) {
            'labels', 'property_keys' => is_string($name) ? ['name_key' => NameKey::of($name)] : [],
            'users' => is_string($email) ? ['email_key' => NameKey::of($email)] : [],
            default => [],
        };
    }

    private static function toDatabase(mixed $value, string $type, string $table, string $column): string|int|null
    {
        if ($value === null || is_int($value)) {
            return $value;
        }
        if (is_float($value)) {
            return (string) $value;
        }
        if (is_array($value)) {
            return json_encode($value, JSON_THROW_ON_ERROR | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        }
        if (is_string($value)) {
            return $type === 'datetime' ? self::databaseTime($value) : $value;
        }

        throw new InvalidArgumentException(sprintf('%s.%s holds a value of an unsupported type.', $table, $column));
    }

    /**
     * @param array<string, string|int|null> $values column names already allow-listed
     */
    private static function insert(PDO $pdo, string $table, array $values): void
    {
        $columns = array_keys($values);
        $sql = sprintf(
            'INSERT INTO `%s` (`%s`) VALUES (%s)',
            $table,
            implode('`, `', $columns),
            implode(', ', array_fill(0, count($columns), '?')),
        );
        $statement = $pdo->prepare($sql);
        if ($statement === false) {
            throw new RuntimeException(sprintf('Cannot prepare the insert into %s.', $table));
        }
        $statement->execute(array_values($values));
    }

    /**
     * Data type per column per table of the connected database; a generated
     * column has the type GENERATED, since nobody may write it.
     *
     * @return array<string, array<string, string>>
     */
    public static function columnTypes(PDO $pdo): array
    {
        $statement = $pdo->query(
            "SELECT TABLE_NAME, COLUMN_NAME, IF(IS_GENERATED = 'NEVER', DATA_TYPE, '" . self::GENERATED . "') "
            . 'FROM information_schema.COLUMNS WHERE TABLE_SCHEMA = DATABASE()',
        );
        $types = [];
        if ($statement === false) {
            return $types;
        }
        foreach ($statement->fetchAll(PDO::FETCH_NUM) as $row) {
            if (is_array($row) && is_string($row[0] ?? null) && is_string($row[1] ?? null) && is_string($row[2] ?? null)) {
                $types[$row[0]][$row[1]] = strtolower($row[2]);
            }
        }

        return $types;
    }
}
