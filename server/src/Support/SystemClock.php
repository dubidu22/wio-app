<?php

declare(strict_types=1);

namespace Wio\Support;

use DateTimeImmutable;
use DateTimeZone;
use Psr\Clock\ClockInterface;

/**
 * The real clock, always in UTC (D-53). Tests use a frozen one (D-120).
 */
final class SystemClock implements ClockInterface
{
    public function now(): DateTimeImmutable
    {
        return new DateTimeImmutable('now', new DateTimeZone('UTC'));
    }
}
