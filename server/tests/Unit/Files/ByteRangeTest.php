<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Files;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\Files\ByteRange;

/**
 * Plan 055 T11: one byte range resolved against a file size (D-230).
 */
final class ByteRangeTest extends TestCase
{
    /**
     * @return iterable<string, array{string, int, array{int, int}|false|null}>
     */
    public static function cases(): iterable
    {
        yield 'first bytes' => ['bytes=0-3', 10, [0, 3]];
        yield 'open end' => ['bytes=4-', 10, [4, 9]];
        yield 'suffix' => ['bytes=-2', 10, [8, 9]];
        yield 'suffix longer than the file' => ['bytes=-20', 10, [0, 9]];
        yield 'end past the file' => ['bytes=7-100', 10, [7, 9]];
        yield 'last byte' => ['bytes=9-9', 10, [9, 9]];
        yield 'spaces and case' => [' BYTES = 1 - 2 ', 10, [1, 2]];
        yield 'start at the end' => ['bytes=10-', 10, false];
        yield 'start past the end' => ['bytes=11-20', 10, false];
        yield 'empty suffix' => ['bytes=-0', 10, false];
        yield 'empty file' => ['bytes=-5', 0, false];
        yield 'several ranges' => ['bytes=0-1,4-5', 10, null];
        yield 'reversed' => ['bytes=5-2', 10, null];
        yield 'other unit' => ['items=0-1', 10, null];
        yield 'no numbers' => ['bytes=-', 10, null];
        yield 'letters' => ['bytes=a-b', 10, null];
        yield 'empty' => ['', 10, null];
        yield 'sixteen digits' => ['bytes=1000000000000000-', 10, null];
    }

    /**
     * @param array{int, int}|false|null $expected
     */
    #[DataProvider('cases')]
    public function testParse(string $header, int $size, array|false|null $expected): void
    {
        \assert($size >= 0);
        $range = ByteRange::parse($header, $size);
        if (!\is_array($expected)) {
            self::assertSame($expected, $range);

            return;
        }
        self::assertInstanceOf(ByteRange::class, $range);
        self::assertSame($expected, [$range->first, $range->last]);
        self::assertSame($expected[1] - $expected[0] + 1, $range->length());
    }
}
