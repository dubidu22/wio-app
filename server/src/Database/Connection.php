<?php

declare(strict_types=1);

namespace Wio\Database;

use PDO;
use RuntimeException;

/**
 * Opens the MariaDB connection from environment variables only; no
 * credentials live in the repository.
 */
final class Connection
{
    private function __construct() {}

    public static function fromEnvironment(): PDO
    {
        $dsn = self::env('WIO_DB_DSN');
        $user = self::env('WIO_DB_USER');
        $password = self::env('WIO_DB_PASSWORD');

        return new PDO($dsn, $user, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);
    }

    private static function env(string $name): string
    {
        $value = getenv($name);
        if ($value === false || $value === '') {
            throw new RuntimeException(sprintf('Environment variable %s is not set.', $name));
        }

        return $value;
    }
}
