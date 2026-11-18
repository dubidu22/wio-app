<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\AppVersion;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\AppVersion\AppVersion;
use Wio\AppVersion\MinimumAppVersion;
use Wio\Tests\Api\Contract;

/**
 * Parsing and comparing app versions (D-140, D-141), plan 033 tests T6 and T7.
 */
final class AppVersionTest extends TestCase
{
    /**
     * @return iterable<string, array{string, ?string}>
     */
    public static function values(): iterable
    {
        yield 'plain' => ['1.2.3', '1.2.3'];
        yield 'with a build' => ['1.2.3+45', '1.2.3'];
        yield 'leading zeros' => ['01.002.3', '1.2.3'];
        yield 'nine-digit parts' => ['999999999.999999999.999999999+9', '999999999.999999999.999999999'];
        yield 'two parts' => ['1.2', null];
        yield 'a pre-release' => ['1.2.3-beta', null];
        yield 'a prefix' => ['v1.2.3', null];
        yield 'a trailing newline' => ["1.2.3\n", null];
        yield 'spaces' => [' 1.2.3', null];
        yield 'two values' => ['1.2.3, 1.2.4', null];
        yield 'a part of 10 digits' => ['1234567890.0.0', null];
        yield 'over 32 characters' => ['123456789.123456789.123456789+123', null];
        yield 'empty' => ['', null];
    }

    #[DataProvider('values')]
    public function testParse(string $value, ?string $parsed): void
    {
        $version = AppVersion::parse($value);
        self::assertSame($parsed, $version === null ? null : (string) $version);
    }

    public function testComparesMajorMinorPatchAsNumbers(): void
    {
        $minimum = AppVersion::minimum('2.3.4');
        foreach (['2.3.3', '2.2.99', '1.99.99', '0.0.0', '2.3.3+999'] as $older) {
            self::assertTrue(self::version($older)->isBelow($minimum), $older);
        }
        foreach (['2.3.4', '2.3.4+0', '2.3.10', '2.10.0', '10.0.0'] as $current) {
            self::assertFalse(self::version($current)->isBelow($minimum), $current);
        }
    }

    public function testAMinimumHasNoBuildPart(): void
    {
        $this->expectException(\LogicException::class);
        AppVersion::minimum('2.0.0+1');
    }

    public function testTheCommittedMinimumIsWellFormed(): void
    {
        $value = (new \ReflectionClassConstant(MinimumAppVersion::class, 'VALUE'))->getValue();
        if ($value === null) {
            $this->expectNotToPerformAssertions();

            return;
        }
        self::assertIsString($value);
        self::assertSame($value, (string) AppVersion::minimum($value));
    }

    public function testThePatternsMatchTheContract(): void
    {
        $components = Contract::map(Contract::document()['components'] ?? null);
        $header = Contract::map(Contract::map(Contract::map($components['parameters'] ?? null)['WioAppVersion'] ?? null)['schema'] ?? null);
        $minimum = Contract::map(Contract::map(Contract::map(Contract::schemas()['Problem'] ?? null)['properties'] ?? null)['minimum_app_version'] ?? null);

        $withoutGroups = str_replace('([0-9]{1,9})', '[0-9]{1,9}', AppVersion::PATTERN);
        self::assertSame($withoutGroups, '/' . self::text($header['pattern'] ?? null) . '/D');
        self::assertSame(AppVersion::MAX_LENGTH, $header['maxLength'] ?? null);
        self::assertSame(AppVersion::MINIMUM_PATTERN, '/' . self::text($minimum['pattern'] ?? null) . '/D');
        self::assertSame(AppVersion::MAX_LENGTH, $minimum['maxLength'] ?? null);
    }

    private static function text(mixed $value): string
    {
        self::assertIsString($value);

        return $value;
    }

    private static function version(string $value): AppVersion
    {
        $version = AppVersion::parse($value);
        self::assertNotNull($version, $value);

        return $version;
    }
}
