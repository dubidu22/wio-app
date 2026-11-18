<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Auth;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Slim\Psr7\Factory\ServerRequestFactory;
use Wio\Auth\BearerToken;

/**
 * The token arrives in the header or, behind CGI/FPM, in a server parameter
 * (D-112), plan 005 test T13.
 */
final class BearerTokenTest extends TestCase
{
    public function testFromTheHeader(): void
    {
        $request = (new ServerRequestFactory())->createServerRequest('GET', '/auth/me')->withHeader('Authorization', 'Bearer wio_abc');

        self::assertSame('wio_abc', BearerToken::from($request));
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function serverParameters(): iterable
    {
        yield 'rewrite rule' => ['HTTP_AUTHORIZATION'];
        yield 'after an internal redirect' => ['REDIRECT_HTTP_AUTHORIZATION'];
    }

    #[DataProvider('serverParameters')]
    public function testFromAServerParameter(string $name): void
    {
        $request = (new ServerRequestFactory())->createServerRequest('GET', '/auth/me', [$name => 'bearer wio_abc']);

        self::assertSame('wio_abc', BearerToken::from($request));
    }

    public function testNoBearerNoToken(): void
    {
        $factory = new ServerRequestFactory();
        self::assertNull(BearerToken::from($factory->createServerRequest('GET', '/auth/me')));
        self::assertNull(BearerToken::from($factory->createServerRequest('GET', '/auth/me')->withHeader('Authorization', 'Basic dXNlcjpwdw==')));
        self::assertNull(BearerToken::from($factory->createServerRequest('GET', '/auth/me')->withHeader('Authorization', 'Bearer ')));
        self::assertNull(BearerToken::from($factory->createServerRequest('GET', '/auth/me')->withHeader('Authorization', 'Bearer a b')));
    }
}
