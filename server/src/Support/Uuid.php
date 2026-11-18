<?php

declare(strict_types=1);

namespace Wio\Support;

use DateTimeImmutable;

/**
 * UUID version 7 (time-ordered, RFC 9562) in the lower-case canonical form
 * the schema checks (D-47).
 */
final class Uuid
{
    private function __construct() {}

    public static function v7(DateTimeImmutable $time): string
    {
        $millis = (int) $time->format('U') * 1000 + intdiv((int) $time->format('u'), 1000);
        $hex = str_pad(dechex($millis), 12, '0', STR_PAD_LEFT) . bin2hex(random_bytes(10));
        $variant = dechex(8 | (hexdec($hex[16]) & 3));

        return sprintf(
            '%s-%s-7%s-%s%s-%s',
            substr($hex, 0, 8),
            substr($hex, 8, 4),
            substr($hex, 13, 3),
            $variant,
            substr($hex, 17, 3),
            substr($hex, 20, 12),
        );
    }
}
