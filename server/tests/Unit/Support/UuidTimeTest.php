<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Support;

use DateTimeImmutable;
use DateTimeZone;
use PHPUnit\Framework\TestCase;
use Wio\Support\Time;
use Wio\Support\Uuid;

final class UuidTimeTest extends TestCase
{
    public function testUuidV7HasTheVersionVariantAndTime(): void
    {
        $time = new DateTimeImmutable('2026-11-18 10:00:00.123', new DateTimeZone('UTC'));
        $ids = [];
        for ($i = 0; $i < 100; ++$i) {
            $id = Uuid::v7($time);
            self::assertMatchesRegularExpression('/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/', $id);
            self::assertSame(str_pad(dechex(1794996000123), 12, '0', STR_PAD_LEFT), str_replace('-', '', substr($id, 0, 13)));
            $ids[$id] = true;
        }
        self::assertCount(100, $ids);
    }

    public function testTimesRoundTripInUtcWithMilliseconds(): void
    {
        $time = Time::fromDatabase('2026-11-18 10:00:00.123');

        self::assertSame('2026-11-18 10:00:00.123', Time::toDatabase($time));
        self::assertSame('2026-11-18T10:00:00.123Z', Time::toJson($time));
        self::assertSame('2026-11-18 09:00:00.000', Time::toDatabase(new DateTimeImmutable('2026-11-18 10:00:00', new DateTimeZone('Europe/Berlin'))));
    }

    public function testSecondsUntilRoundsUp(): void
    {
        $from = Time::fromDatabase('2026-11-18 10:00:00.000');

        self::assertSame(1, Time::secondsUntil($from, Time::fromDatabase('2026-11-18 10:00:00.001')));
        self::assertSame(800, Time::secondsUntil($from, Time::fromDatabase('2026-11-18 10:13:20.000')));
        self::assertSame(0, Time::secondsUntil($from, $from));
    }
}
