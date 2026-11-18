<?php

declare(strict_types=1);

namespace Wio\Ops;

/**
 * The rule for passwords that the ops scripts set (D-115). Sign-in itself
 * never rejects a short password.
 */
final class OwnerPassword
{
    public const int MIN_LENGTH = 12;
    public const int MAX_LENGTH = 1024;

    private function __construct() {}

    public static function check(#[\SensitiveParameter] string $password): void
    {
        $length = mb_strlen($password, 'UTF-8');
        if ($length < self::MIN_LENGTH || $length > self::MAX_LENGTH) {
            throw new OpsException(sprintf('The password must have %d to %d characters.', self::MIN_LENGTH, self::MAX_LENGTH));
        }
    }
}
