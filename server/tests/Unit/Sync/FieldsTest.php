<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Sync;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\Sync\Fields;
use Wio\Sync\Rejected;

/**
 * The record-schema checks and conversions of pushed fields (D-177).
 */
final class FieldsTest extends TestCase
{
    /**
     * @return iterable<string, array{array<string, mixed>, mixed, bool}>
     */
    public static function values(): iterable
    {
        $uuid = ['type' => 'string', 'format' => 'uuid'];
        $time = ['type' => 'string', 'format' => 'date-time'];
        $int32 = ['type' => 'integer', 'format' => 'int32', 'minimum' => 0];
        yield 'uuid' => [$uuid, '01990000-0000-7000-8000-000000000001', true];
        yield 'uuid upper case' => [$uuid, '01990000-0000-7000-8000-00000000000A', true];
        yield 'uuid short' => [$uuid, '01990000-0000-7000-8000-00000000001', false];
        yield 'null where not nullable' => [$uuid, null, false];
        yield 'null where nullable' => [['nullable' => true] + $uuid, null, true];
        yield 'any value' => [[], ['a' => 1], true];
        yield 'time with Z' => [$time, '2026-11-18T10:00:00.000Z', true];
        yield 'time with offset' => [$time, '2026-11-18T10:00:00+01:00', true];
        yield 'time without zone' => [$time, '2026-11-18T10:00:00', false];
        yield 'time 25 o\'clock' => [$time, '2026-11-18T25:00:00Z', false];
        yield 'time 30 February' => [$time, '2026-02-30T10:00:00Z', false];
        yield 'time before year 1000' => [$time, '0999-01-01T00:00:00Z', false];
        yield 'date' => [['type' => 'string', 'format' => 'date'], '2028-02-29', true];
        yield 'date not leap' => [['type' => 'string', 'format' => 'date'], '2026-02-29', false];
        yield 'int32' => [$int32, 2147483647, true];
        yield 'int32 too big' => [$int32, 2147483648, false];
        yield 'below minimum' => [$int32, -1, false];
        yield 'float for integer' => [$int32, 1.0, false];
        yield 'string for integer' => [$int32, '1', false];
        yield 'enum' => [['type' => 'string', 'enum' => ['door', 'window']], 'gate', false];
        yield 'max length counts characters' => [['type' => 'string', 'maxLength' => 3], 'äöü', true];
        yield 'max length' => [['type' => 'string', 'maxLength' => 3], 'abcd', false];
        yield 'pattern' => [['type' => 'string', 'pattern' => Fields::DECIMAL_PATTERN], '-12.5', true];
        yield 'pattern broken' => [['type' => 'string', 'pattern' => Fields::DECIMAL_PATTERN], '12.', false];
        yield 'array' => [['type' => 'array', 'items' => ['type' => 'integer']], [1, 2], true];
        yield 'array item' => [['type' => 'array', 'items' => ['type' => 'integer']], [1, 'x'], false];
        yield 'object for array' => [['type' => 'array'], (object) ['a' => 1], false];
        yield 'list for object' => [['type' => 'object'], [1], false];
        yield 'object' => [['type' => 'object'], (object) [], true];
        yield 'object required' => [['type' => 'object', 'required' => ['x'], 'properties' => ['x' => ['type' => 'integer']]], (object) ['y' => 1], false];
        yield 'object property' => [['type' => 'object', 'properties' => ['x' => ['type' => 'integer']]], (object) ['x' => 'a'], false];
        yield 'object closed' => [['type' => 'object', 'additionalProperties' => false], (object) ['x' => 1], false];
        yield 'invalid UTF-8' => [['type' => 'string'], "\xC3\x28", false];
    }

    /**
     * @param array<string, mixed> $schema
     */
    #[DataProvider('values')]
    public function testValidate(array $schema, mixed $value, bool $valid): void
    {
        try {
            Fields::validate($schema, $value, 'f');
            self::assertTrue($valid, 'accepted');
        } catch (Rejected $e) {
            self::assertFalse($valid, $e->getMessage());
            self::assertSame('invalid', $e->reason);
        }
    }

    public function testConversionToTheDatabaseAndBack(): void
    {
        $time = ['type' => 'string', 'format' => 'date-time'];
        self::assertSame('2026-11-18 09:00:00.123', Fields::toDatabase($time, '2026-11-18T10:00:00.123+01:00'));
        self::assertSame('2026-11-18T09:00:00.123Z', Fields::fromDatabase($time, '2026-11-18 09:00:00.123'));
        self::assertSame('01990000-0000-7000-8000-00000000000a', Fields::toDatabase(['type' => 'string', 'format' => 'uuid'], '01990000-0000-7000-8000-00000000000A'));
        self::assertSame('{"a":[1,2]}', Fields::toDatabase(['type' => 'object'], (object) ['a' => [1, 2]]));
        self::assertEquals((object) [], Fields::fromDatabase(['type' => 'object'], '{}'), 'an empty object stays an object');
        self::assertSame(12, Fields::fromDatabase(['type' => 'integer'], '12'));
        $decimal = ['type' => 'string', 'pattern' => Fields::DECIMAL_PATTERN];
        self::assertSame('-3.25', Fields::fromDatabase($decimal, '-3.250000'));
        self::assertSame('12', Fields::fromDatabase($decimal, '12.000000'));
        self::assertSame('120', Fields::fromDatabase($decimal, '120'));
        self::assertSame('12.000000', Fields::fromDatabase(['type' => 'string'], '12.000000'), 'only decimals are trimmed');
    }

    public function testCanonicalSortsObjectKeysAtEveryDepth(): void
    {
        self::assertSame(
            Fields::canonical((object) ['b' => 1, 'a' => [(object) ['d' => 1, 'c' => 2]]]),
            Fields::canonical((object) ['a' => [(object) ['c' => 2, 'd' => 1]], 'b' => 1]),
        );
        self::assertNotSame(Fields::canonical([1, 2]), Fields::canonical([2, 1]), 'lists keep their order');
    }
}
