<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Ops;

use PDO;
use PDOStatement;
use RuntimeException;
use Wio\Database\Connection;

/**
 * A connection that runs a hook once, right before it prepares the first
 * query containing a marker. Lets a test commit a change on another
 * connection at an exact point of a transaction.
 */
final class HookedPdo extends PDO
{
    /** @var (\Closure(): void)|null */
    private ?\Closure $hook = null;

    private string $marker = '';

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
     * @param \Closure(): void $hook
     */
    public function before(string $marker, \Closure $hook): void
    {
        $this->marker = $marker;
        $this->hook = $hook;
    }

    public function ran(): bool
    {
        return $this->hook === null;
    }

    /**
     * @param array<int|string, mixed> $options
     */
    public function prepare(string $query, array $options = []): PDOStatement|false
    {
        $hook = $this->hook;
        if ($hook !== null && str_contains($query, $this->marker)) {
            $this->hook = null;
            $hook();
        }

        return parent::prepare($query, $options);
    }
}
