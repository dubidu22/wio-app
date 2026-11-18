<?php

declare(strict_types=1);

namespace Wio\Migration;

/**
 * Reads the migration files of a directory, in version order, and rejects
 * anything ambiguous: a .sql file with a bad name, or two files with the same
 * number.
 */
final class MigrationSet
{
    public const string NAME_PATTERN = '/^(\d{4})_[a-z0-9_]+\.sql$/';

    private function __construct() {}

    /**
     * @return list<Migration>
     */
    public static function fromDirectory(string $directory): array
    {
        if (!is_dir($directory)) {
            throw new MigrationException(sprintf('Migration directory %s does not exist.', $directory));
        }

        $files = glob(rtrim($directory, '/') . '/*.sql');
        if ($files === false) {
            throw new MigrationException(sprintf('Cannot list %s.', $directory));
        }

        $byNumber = [];
        foreach ($files as $path) {
            $name = basename($path);
            if (preg_match(self::NAME_PATTERN, $name, $match) !== 1) {
                throw new MigrationException(sprintf(
                    'Migration file %s must be named NNNN_description.sql (lower case, digits, underscores).',
                    $name,
                ));
            }
            $number = $match[1];
            if (isset($byNumber[$number])) {
                throw new MigrationException(sprintf(
                    'Migrations %s and %s share the number %s.',
                    basename($byNumber[$number]->path),
                    $name,
                    $number,
                ));
            }
            $sql = file_get_contents($path);
            if ($sql === false) {
                throw new MigrationException(sprintf('Cannot read %s.', $path));
            }
            $byNumber[$number] = new Migration(substr($name, 0, -4), $path, hash('sha256', $sql));
        }

        ksort($byNumber, SORT_STRING);

        return array_values($byNumber);
    }
}
