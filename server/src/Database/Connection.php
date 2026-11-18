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
    /**
     * Shared hosting defaults vary, so every connection sets UTC and a strict
     * SQL mode itself (D-53): an invalid value fails instead of being silently
     * changed, and server times never depend on the host's time zone.
     */
    public const string SQL_MODE = 'STRICT_ALL_TABLES,NO_ZERO_DATE,NO_ZERO_IN_DATE,'
        . 'ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

    private const string SESSION_SETUP = "SET time_zone = '+00:00', sql_mode = '" . self::SQL_MODE . "'";

    private function __construct() {}

    public static function fromEnvironment(): PDO
    {
        $dsn = self::env('WIO_DB_DSN');
        $user = self::env('WIO_DB_USER');
        $password = self::env('WIO_DB_PASSWORD');

        return new PDO($dsn, $user, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::MYSQL_ATTR_INIT_COMMAND => self::SESSION_SETUP,
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
