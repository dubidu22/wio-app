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

    public function testRefusesADatabaseThatHasTablesButNoMigrationHistory(): void
    {
        $this->pdo->exec('CREATE TABLE stray (id INT PRIMARY KEY)');

        try {
            (new Runner($this->pdo, self::FIXTURES . '/ok'))->migrate();
            self::fail('A database with foreign tables and no history must be refused.');
        } catch (MigrationException $e) {
            self::assertStringContainsString('no migration history', $e->getMessage());
        }

        self::assertSame([], $this->recordedVersions());
        self::assertSame(['schema_migrations', 'stray'], $this->tables());
    }

    public function testRefusesToRunWhileAnotherRunOnTheSameDatabaseHoldsTheLock(): void
    {
        // Spelled out rather than taken from Runner, so the test pins the name.
        $name = "CONCAT('wio_migrate_', LEFT(SHA2(DATABASE(), 256), 32))";
        $other = Connection::fromEnvironment();
        $lock = $other->query("SELECT GET_LOCK({$name}, 0)");
        self::assertNotFalse($lock);
        self::assertSame('1', $this->scalar($lock->fetchColumn()));

        try {
            (new Runner($this->pdo, self::FIXTURES . '/ok', 0))->migrate();
            self::fail('A second run must not start while the lock is held.');
        } catch (MigrationException $e) {
            self::assertStringContainsString('holds the lock', $e->getMessage());
        } finally {
            $other->query("SELECT RELEASE_LOCK({$name})");
        }

        self::assertNotContains('alpha', $this->tables());
    }

    public function testTheLockOfAnotherDatabaseDoesNotBlock(): void
    {
        $other = Connection::fromEnvironment();
        $name = "CONCAT('wio_migrate_', LEFT(SHA2('wio_other_database', 256), 32))";
        $lock = $other->query("SELECT GET_LOCK({$name}, 0)");
        self::assertNotFalse($lock);
        self::assertSame('1', $this->scalar($lock->fetchColumn()));

        try {
            $applied = (new Runner($this->pdo, self::FIXTURES . '/ok', 0))->migrate();
        } finally {
            $other->query("SELECT RELEASE_LOCK({$name})");
        }

        self::assertSame(['0001_create_alpha', '0002_create_beta'], $applied);
    }

    public function testTheRealMigrationsApplyToAnEmptyDatabaseOnce(): void
    {
        $applied = (new Runner($this->pdo, __DIR__ . '/../../migrations'))->migrate();

        self::assertSame([
            '0001_workspaces_users',
            '0002_customers_places',
            '0003_vocabulary',
            '0004_entries_history',
            '0005_pictures_notes',
            '0006_jobs',
            '0007_sync_support',
            '0008_user_passwords',
            '0009_device_tokens',
            '0010_sign_in_failures',
            '0011_users_email_key_index',
            '0012_applied_changes',
            '0013_field_versions',
            '0014_pictures_file_sha256_index',
            '0015_notes_audio_sha256_index',
        ], $applied);
        self::assertSame([
            'applied_changes', 'conflicts', 'customers', 'device_tokens', 'entity_labels', 'entity_properties', 'entries', 'expenses',
            'field_versions', 'fixtures', 'jobs', 'labels', 'notes', 'openings', 'pictures', 'place_history', 'property_keys', 'rooms',
            'schema_migrations', 'sign_in_failures', 'sign_offs', 'sites', 'time_blocks', 'user_passwords', 'users',
            'workspace_counters', 'workspaces',
        ], $this->tables());
        self::assertSame([], (new Runner($this->pdo, __DIR__ . '/../../migrations'))->migrate());
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

    private function scalar(mixed $value): string
    {
        return is_scalar($value) ? (string) $value : '';
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
