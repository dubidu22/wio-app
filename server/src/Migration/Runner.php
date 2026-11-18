<?php

declare(strict_types=1);

namespace Wio\Migration;

use PDO;
use PDOException;
use PDOStatement;

/**
 * Applies the SQL files of server/migrations/ in order (D-38).
 *
 * MariaDB commits DDL implicitly, so a file cannot be rolled back. The runner
 * therefore records a file only after all of its statements succeeded, stops
 * at the first error, and refuses to run when an applied file was changed.
 * It is plain PHP so that it can run from the command line, a cron job or a
 * protected endpoint (O-6, D-56).
 *
 * Further guards (D-55): a run refuses a database that has tables but no
 * migration history, because the first files expect an empty database; and a
 * lock keeps two runs from interleaving.
 */
final class Runner
{
    private const string TABLE = 'schema_migrations';
    /**
     * GET_LOCK names are global to the MariaDB server, so the name carries a
     * hash of the database name: staging and production on one server do not
     * block each other (44 characters, under the limit of 64).
     */
    public const string LOCK_NAME_SQL = "CONCAT('wio_migrate_', LEFT(SHA2(DATABASE(), 256), 32))";
    private const int LOCK_TIMEOUT_SECONDS = 30;

    public function __construct(
        private readonly PDO $pdo,
        private readonly string $directory,
        private readonly int $lockTimeoutSeconds = self::LOCK_TIMEOUT_SECONDS,
    ) {
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        // Files with several statements need emulated prepares.
        $this->pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, true);
    }

    /**
     * @return list<string> versions applied by this call, in order
     */
    public function migrate(): array
    {
        $migrations = MigrationSet::fromDirectory($this->directory);
        $this->lock();
        try {
            $this->createTable();
            $applied = $this->appliedChecksums();
            $this->assertAppliedUnchanged($migrations, $applied);
            if ($applied === [] && $migrations !== []) {
                $this->assertNoOtherTables();
            }

            $done = [];
            foreach ($migrations as $migration) {
                if (isset($applied[$migration->version])) {
                    continue;
                }
                $this->apply($migration);
                $done[] = $migration->version;
            }

            return $done;
        } finally {
            $this->unlock();
        }
    }

    private function apply(Migration $migration): void
    {
        $sql = file_get_contents($migration->path);
        if ($sql === false) {
            throw new MigrationException(sprintf('Cannot read %s.', $migration->path));
        }

        try {
            // A file may hold several statements. PDO reports an error in a
            // later statement only while walking the result sets.
            $statement = $this->pdo->query($sql);
            if ($statement instanceof PDOStatement) {
                do {
                    $statement->closeCursor();
                } while ($statement->nextRowset());
            }
        } catch (PDOException $e) {
            throw new MigrationException(
                sprintf('Migration %s failed: %s', $migration->version, $e->getMessage()),
                0,
                $e,
            );
        }

        $this->prepare(
            'INSERT INTO ' . self::TABLE . ' (version, checksum, applied_at) VALUES (?, ?, UTC_TIMESTAMP(6))',
        )->execute([$migration->version, $migration->checksum]);
    }

    private function createTable(): void
    {
        $this->pdo->exec(
            'CREATE TABLE IF NOT EXISTS ' . self::TABLE . ' ('
            . 'version VARCHAR(191) NOT NULL PRIMARY KEY, '
            . 'checksum CHAR(64) NOT NULL, '
            . 'applied_at DATETIME(6) NOT NULL'
            . ') ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin',
        );
    }

    /**
     * @return array<string, string> version => checksum
     */
    private function appliedChecksums(): array
    {
        $statement = $this->pdo->query('SELECT version, checksum FROM ' . self::TABLE);
        if ($statement === false) {
            throw new MigrationException('Cannot read ' . self::TABLE . '.');
        }

        $applied = [];
        foreach ($statement->fetchAll(PDO::FETCH_NUM) as $row) {
            if (is_array($row) && is_string($row[0] ?? null) && is_string($row[1] ?? null)) {
                $applied[$row[0]] = $row[1];
            }
        }

        return $applied;
    }

    /**
     * @param list<Migration> $migrations
     * @param array<string, string> $applied
     */
    private function assertAppliedUnchanged(array $migrations, array $applied): void
    {
        $onDisk = [];
        foreach ($migrations as $migration) {
            $onDisk[$migration->version] = $migration->checksum;
        }

        foreach ($applied as $version => $checksum) {
            if (!isset($onDisk[$version])) {
                throw new MigrationException(sprintf('Applied migration %s is missing on disk.', $version));
            }
            if (!hash_equals($checksum, $onDisk[$version])) {
                throw new MigrationException(sprintf(
                    'Applied migration %s was changed after it ran; add a new migration instead.',
                    $version,
                ));
            }
        }
    }

    private function assertNoOtherTables(): void
    {
        $statement = $this->prepare(
            'SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME <> ?',
        );
        $statement->execute([self::TABLE]);
        if ((string) $statement->fetchColumn() !== '0') {
            throw new MigrationException(
                'The database has tables but no migration history; migrations run only on an empty database '
                . 'or on one they created.',
            );
        }
    }

    private function lock(): void
    {
        $statement = $this->prepare('SELECT GET_LOCK(' . self::LOCK_NAME_SQL . ', ?)');
        $statement->execute([$this->lockTimeoutSeconds]);
        if ((string) $statement->fetchColumn() !== '1') {
            throw new MigrationException('Another migration run holds the lock.');
        }
    }

    private function unlock(): void
    {
        $this->prepare('SELECT RELEASE_LOCK(' . self::LOCK_NAME_SQL . ')')->execute();
    }

    private function prepare(string $sql): PDOStatement
    {
        $statement = $this->pdo->prepare($sql);
        if ($statement === false) {
            throw new MigrationException('Cannot prepare: ' . $sql);
        }

        return $statement;
    }
}
