<?php

declare(strict_types=1);

namespace Wio\Http\Files;

use Wio\Http\InvalidRequest;

/**
 * The `{sha256}` path parameter of the file operations.
 */
final class FileArguments
{
    private function __construct() {}

    /**
     * @param array<string, string> $arguments
     *
     * @throws InvalidRequest
     */
    public static function sha256(array $arguments): string
    {
        $sha256 = $arguments['sha256'] ?? '';
        if (preg_match('/^[0-9a-f]{64}$/', $sha256) !== 1) {
            throw new InvalidRequest('sha256 must be 64 lower-case hex digits.');
        }

        return $sha256;
    }
}
