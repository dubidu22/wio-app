<?php

declare(strict_types=1);

namespace Wio\Config;

use RuntimeException;

/**
 * Host configuration outside the web root (D-161). On the hosting, the deploy
 * writes `shared/config.php` from the environment's GitHub secrets and links
 * it into each release as `config.php` next to `public/`. The file returns
 * `['WIO_DB_DSN' => '…', …]`. A variable the real environment already sets
 * wins, so CI and local runs, which have no such file, are unchanged.
 */
final class HostConfig
{
    private function __construct() {}

    /**
     * Loads the file if it exists and returns the names it set.
     *
     * @return list<string>
     */
    public static function load(string $file): array
    {
        if (!is_file($file)) {
            return [];
        }

        $values = require $file;
        if (!\is_array($values)) {
            throw new RuntimeException('The host config must return an array.');
        }

        $set = [];
        foreach ($values as $name => $value) {
            if (!\is_string($name) || preg_match('/^WIO_[A-Z0-9_]+$/', $name) !== 1) {
                throw new RuntimeException('Host config names must look like WIO_NAME.');
            }
            if (!\is_string($value)) {
                throw new RuntimeException(sprintf('Host config value %s must be a string.', $name));
            }
            if (getenv($name) !== false) {
                continue;
            }
            putenv("{$name}={$value}");
            $set[] = $name;
        }

        return $set;
    }
}
