<?php

declare(strict_types=1);

namespace Wio\Auth;

/**
 * A device token: `wio_` + base64url of 32 random bytes (D-110). The server
 * keeps only its SHA-256.
 */
final class DeviceToken
{
    public const string PREFIX = 'wio_';

    private const string PATTERN = '/^wio_[A-Za-z0-9_-]{43}$/';

    private function __construct() {}

    public static function generate(): string
    {
        return self::PREFIX . rtrim(strtr(base64_encode(random_bytes(32)), '+/', '-_'), '=');
    }

    public static function hash(#[\SensitiveParameter] string $token): string
    {
        return hash('sha256', $token);
    }

    public static function looksValid(#[\SensitiveParameter] string $token): bool
    {
        return preg_match(self::PATTERN, $token) === 1;
    }
}
