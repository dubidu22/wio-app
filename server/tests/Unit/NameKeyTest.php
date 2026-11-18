<?php

declare(strict_types=1);

namespace Wio\Tests\Unit;

use PHPUnit\Framework\TestCase;
use Wio\Schema\NameKey;

/**
 * D-51: the key that makes names unique per workspace.
 */
final class NameKeyTest extends TestCase
{
    public function testCaseAndOuterSpacesDoNotMatter(): void
    {
        self::assertSame('küche', NameKey::of('Küche'));
        self::assertSame('küche', NameKey::of(' küche '));
        self::assertSame('küche', NameKey::of('KÜCHE'));
    }

    public function testAnUmlautIsNotTheSameLetterWithoutIt(): void
    {
        self::assertNotSame(NameKey::of('Küche'), NameKey::of('Kuche'));
    }

    public function testDecomposedInputEqualsComposedInput(): void
    {
        self::assertSame(NameKey::of("Ku\u{0308}che"), NameKey::of("K\u{00FC}che"));
    }

    public function testInnerWhiteSpaceCollapsesToOneSpace(): void
    {
        self::assertSame('erstes regal', NameKey::of("Erstes \t  Regal"));
        self::assertSame('erstes regal', NameKey::of("Erstes\u{00A0}Regal"));
    }

    public function testInvalidUtf8IsRejected(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        NameKey::of("K\xC3che");
    }
}
