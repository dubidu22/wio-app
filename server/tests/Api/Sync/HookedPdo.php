<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use PDO;
use PDOStatement;
use RuntimeException;
use Wio\Database\Connection;

/**
 * A connection that runs a hook once, right before Pull fetches the full rows
 * of the records its id list found (the first `SELECT * FROM` it prepares).
 * Lets a test commit a change on another connection between the two reads.
 */
final class HookedPdo extends PDO
{
    /** @var (\Closure(): void)|null */
    public ?\Closure $beforeRowFetch = null;

    public static function fromEnvironment(): self
    {
        $env = static fn(string $name): string => \is_string($value = getenv($name)) && $value !== ''
            ? $value
            : throw new RuntimeException("{$name} is not set.");

        return new self($env('WIO_DB_DSN'), $env('WIO_DB_USER'), $env('WIO_DB_PASSWORD'), [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET time_zone = '+00:00', sql_mode = '" . Connection::SQL_MODE . "'",
        ]);
    }

    /**
     * @param array<int|string, mixed> $options
     */
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $hook = $this->beforeRowFetch;
        if ($hook !== null && str_starts_with($query, 'SELECT * FROM ')) {
            $this->beforeRowFetch = null;
            $hook();
        }

        return parent::prepare($query, $options);
    }
}
