<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Auth;

use PHPUnit\Framework\TestCase;
use Wio\Auth\DeviceToken;

/**
 * The token format (D-110).
 */
final class DeviceTokenTest extends TestCase
{
    public function testATokenIsWioAnd32RandomBytes(): void
    {
        $tokens = [];
        for ($i = 0; $i < 50; ++$i) {
            $token = DeviceToken::generate();
            self::assertMatchesRegularExpression('/^wio_[A-Za-z0-9_-]{43}$/', $token);
            self::assertTrue(DeviceToken::looksValid($token));
            self::assertSame(32, \strlen((string) base64_decode(strtr(substr($token, 4), '-_', '+/') . '=', true)));
            $tokens[$token] = true;
        }
        self::assertCount(50, $tokens);
    }

    public function testOnlyTheSha256IsKept(): void
    {
        self::assertSame(hash('sha256', 'wio_beispiel'), DeviceToken::hash('wio_beispiel'));
    }

    public function testOtherShapesAreNotTokens(): void
    {
        foreach (['', 'wio_', 'abc', 'wio_' . str_repeat('a', 42), 'wio_' . str_repeat('a', 44), 'WIO_' . str_repeat('a', 43), 'wio_' . str_repeat('a', 42) . '='] as $value) {
            self::assertFalse(DeviceToken::looksValid($value), $value);
        }
    }
}
