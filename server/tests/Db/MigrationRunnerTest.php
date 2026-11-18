<?php

declare(strict_types=1);

namespace Wio\Tests\Db;

use PDO;
use PHPUnit\Framework\TestCase;
use Wio\Database\Connection;
use Wio\Migration\MigrationException;
use Wio\Migration\Runner;

/**
 * Runs against the MariaDB named by WIO_DB_DSN (a service container in CI).
 * Every test starts from an empty database.
 */
final class MigrationRunnerTest extends TestCase
{
    private const string FIXTURES = __DIR__ . '/../fixtures/migrations';

    private PDO $pdo;

    protected function setUp(): void
    {
        $this->pdo = Connection::fromEnvironment();
        $this->dropAllTables();
    }

    protected function tearDown(): void
    {
        $this->dropAllTables();
    }

    public function testAppliesAllFilesInOrderFromAnEmptyDatabase(): void
    {
        $applied = (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();

        self::assertSame(['0001_create_alpha', '0002_create_beta'], $applied);
        self::assertSame(['alpha', 'beta', 'schema_migrations'], $this->tables());
        self::assertSame(['0001_create_alpha', '0002_create_beta'], $this->recordedVersions());
        self::assertSame(['1', '2'], $this->column('SELECT id FROM beta ORDER BY id'));
    }

    public function testASecondRunAppliesNothing(): void
    {
        (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();

        $applied = (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();

        self::assertSame([], $applied);
    }

    public function testStopsAtAFailingStatementAndRecordsOnlyEarlierFiles(): void
    {
        try {
            (new Runner($this->pdo, self::FIXTURES . '/broken'))->migrate();
            self::fail('The broken migration must fail.');
        } catch (MigrationException $e) {
            self::assertStringContainsString('0002_second_statement_fails', $e->getMessage());
        }

        self::assertSame(['0001_create_alpha'], $this->recordedVersions());
        self::assertNotContains('gamma', $this->tables());
    }

    public function testRefusesToRunWhenAnAppliedFileChanged(): void
    {
        (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();
        $this->pdo->exec("UPDATE schema_migrations SET checksum = REPEAT('0', 64) WHERE version = '0001_create_alpha'");

        $this->expectException(MigrationException::class);
        $this->expectExceptionMessage('was changed after it ran');
        (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();
    }

    public function testRefusesToRunWhenAnAppliedFileIsMissing(): void
    {
        (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();
        $this->pdo->exec("INSERT INTO schema_migrations VALUES ('0009_gone', REPEAT('0', 64), UTC_TIMESTAMP(6))");

        $this->expectException(MigrationException::class);
        $this->expectExceptionMessage('missing on disk');
        (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();
    }

    public function testTheRealMigrationsApplyToAnEmptyDatabase(): void
    {
        (new Runner($this->pdo, __DIR__ . '/../../migrations'))->migrate();

        self::assertContains('schema_migrations', $this->tables());
    }

    /**
     * @return list<string>
     */
    private function tables(): array
    {
        $names = $this->column('SHOW TABLES');
        sort($names);

        return $names;
    }

    /**
     * @return list<string>
     */
    private function recordedVersions(): array
    {
        return $this->column('SELECT version FROM schema_migrations ORDER BY version');
    }

    /**
     * @return list<string> the first column of every row, as strings
     */
    private function column(string $sql): array
    {
        $statement = $this->pdo->query($sql);
        self::assertNotFalse($statement);

        return array_values(array_map(
            static fn(mixed $value): string => is_scalar($value) ? (string) $value : '',
            $statement->fetchAll(PDO::FETCH_COLUMN),
        ));
    }

    private function dropAllTables(): void
    {
        $this->pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
        foreach ($this->tables() as $table) {
            $this->pdo->exec('DROP TABLE `' . str_replace('`', '``', $table) . '`');
        }
        $this->pdo->exec('SET FOREIGN_KEY_CHECKS = 1');
    }
}
