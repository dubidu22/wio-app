<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

use PDO;
use PDOException;
use PHPUnit\Framework\TestCase;
use Wio\Database\Connection;
use Wio\Migration\Runner;

/**
 * Migrates an empty database once per class; every test runs in a
 * transaction that is rolled back, so tests do not see each other's rows.
 */
abstract class SchemaTestCase extends TestCase
{
    /** MariaDB error numbers the schema's safety nets raise. */
    protected const int FOREIGN_KEY = 1452;
    protected const int CHECK = 4025;
    protected const int DUPLICATE = 1062;

    protected PDO $pdo;
    protected Rows $rows;

    public static function setUpBeforeClass(): void
    {
        $pdo = Connection::fromEnvironment();
        self::dropAllTables($pdo);
        (new Runner($pdo, __DIR__ . '/../../../migrations'))->migrate();
    }

    public static function tearDownAfterClass(): void
    {
        self::dropAllTables(Connection::fromEnvironment());
    }

    protected function setUp(): void
    {
        $this->pdo = Connection::fromEnvironment();
        $this->rows = new Rows($this->pdo);
        $this->pdo->beginTransaction();
    }

    protected function tearDown(): void
    {
        if ($this->pdo->inTransaction()) {
            $this->pdo->rollBack();
        }
    }

    /**
     * Asserts that the write fails with the given MariaDB error number.
     */
    protected function assertRejected(int $errorNumber, callable $write): void
    {
        try {
            $write();
        } catch (PDOException $e) {
            $actual = $e->errorInfo[1] ?? null;
            self::assertSame($errorNumber, $actual, $e->getMessage());

            return;
        }
        self::fail(sprintf('The write was accepted; expected MariaDB error %d.', $errorNumber));
    }

    /**
     * @return list<array<string, mixed>>
     */
    protected function rowsOf(string $sql): array
    {
        $statement = $this->pdo->query($sql);
        self::assertNotFalse($statement);

        /** @var list<array<string, mixed>> */
        return $statement->fetchAll(PDO::FETCH_ASSOC);
    }

    public static function dropAllTables(PDO $pdo): void
    {
        $statement = $pdo->query('SHOW TABLES');
        $tables = $statement === false ? [] : $statement->fetchAll(PDO::FETCH_COLUMN);
        $pdo->exec('SET FOREIGN_KEY_CHECKS = 0');
        foreach ($tables as $table) {
            if (is_string($table)) {
                $pdo->exec('DROP TABLE `' . str_replace('`', '``', $table) . '`');
            }
        }
        $pdo->exec('SET FOREIGN_KEY_CHECKS = 1');
    }
}
