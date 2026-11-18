<?php

declare(strict_types=1);

namespace Wio\Tests\Support;

use PDO;
use Wio\Database\Connection;
use Wio\Migration\Runner;
use Wio\Tests\Db\Schema\SchemaTestCase;

/**
 * A migrated test database for code that runs its own transactions, so a
 * test cannot be rolled back: every test starts with empty tables instead.
 */
final class MigratedDatabase
{
    private function __construct() {}

    public static function migrate(): void
    {
        $pdo = Connection::fromEnvironment();
        SchemaTestCase::dropAllTables($pdo);
        (new Runner($pdo, __DIR__ . '/../../migrations'))->migrate();
    }

    public static function drop(): void
    {
        SchemaTestCase::dropAllTables(Connection::fromEnvironment());
    }

    /**
     * Empties every table except the migration history.
     */
    public static function empty(PDO $pdo): void
    {
        $statement = $pdo->query('SHOW TABLES');
        $tables = $statement === false ? [] : $statement->fetchAll(PDO::FETCH_COLUMN);
        $pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
        foreach ($tables as $table) {
            if (\is_string($table) && $table !== 'schema_migrations') {
                $pdo->exec('DELETE FROM `' . str_replace('`', '``', $table) . '`');
            }
        }
        $pdo->exec('SET FOREIGN_KEY_CHECKS = 1');
    }
}
