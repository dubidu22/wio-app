<?php

declare(strict_types=1);

namespace Wio\Support;

use DateTimeImmutable;
use DateTimeZone;
use RuntimeException;

/**
 * Converts between PHP times, DATETIME(3) columns and the contract's
 * date-time strings. Every server time is UTC (D-53).
 */
final class Time
{
    private const string DATABASE = 'Y-m-d H:i:s.v';

    private function __construct() {}

    public static function toDatabase(DateTimeImmutable $time): string
    {
        return $time->setTimezone(new DateTimeZone('UTC'))->format(self::DATABASE);
    }

    public static function fromDatabase(string $value): DateTimeImmutable
    {
        $time = DateTimeImmutable::createFromFormat('!' . self::DATABASE, $value, new DateTimeZone('UTC'));
        if ($time === false) {
            throw new RuntimeException('Not a DATETIME(3) value: ' . $value);
        }

        return $time;
    }

    /**
     * RFC 3339 in UTC with milliseconds, as the contract's date-time fields.
     */
    public static function toJson(DateTimeImmutable $time): string
    {
        return $time->setTimezone(new DateTimeZone('UTC'))->format('Y-m-d\TH:i:s.v\Z');
    }

    /**
     * Whole seconds from $from to $to, rounded up.
     */
    public static function secondsUntil(DateTimeImmutable $from, DateTimeImmutable $to): int
    {
        $micros = ((int) $to->format('U') - (int) $from->format('U')) * 1_000_000
            + ((int) $to->format('u') - (int) $from->format('u'));

        return intdiv($micros + 999_999, 1_000_000);
    }
}
