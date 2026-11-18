<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Auth;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\Auth\SignInLimiter;

/**
 * The address the per-IP sign-in limit counts (D-137).
 */
final class SignInLimiterKeyTest extends TestCase
{
    /**
     * @return iterable<string, array{string, string}>
     */
    public static function keys(): iterable
    {
        yield 'IPv4 unchanged' => ['192.0.2.10', '192.0.2.10'];
        yield 'IPv4-mapped IPv6' => ['::ffff:192.0.2.10', '192.0.2.10'];
        yield 'IPv4-mapped IPv6 in hex' => ['::FFFF:c000:020a', '192.0.2.10'];
        yield 'IPv6 by its /64' => ['2001:db8:1:2::1', '2001:db8:1:2::/64'];
        yield 'IPv6 written in full' => ['2001:0DB8:0001:0002:abcd:ef01:2345:6789', '2001:db8:1:2::/64'];
        yield 'IPv6 loopback' => ['::1', '::/64'];
        yield 'not an address' => ['unix-socket', 'unix-socket'];
    }

    #[DataProvider('keys')]
    public function testKey(string $ip, string $key): void
    {
        self::assertSame($key, SignInLimiter::ipKey($ip));
        self::assertSame(hash('sha256', $key), SignInLimiter::ipHash($ip));
    }

    public function testTheSameSlashSixtyFourSharesAHashAndAnotherDoesNot(): void
    {
        self::assertSame(SignInLimiter::ipHash('2001:db8:1:2::1'), SignInLimiter::ipHash('2001:db8:1:2:ffff:ffff:ffff:ffff'));
        self::assertNotSame(SignInLimiter::ipHash('2001:db8:1:2::1'), SignInLimiter::ipHash('2001:db8:1:3::1'));
        self::assertSame(SignInLimiter::ipHash('192.0.2.10'), SignInLimiter::ipHash('::ffff:192.0.2.10'));
    }
}
