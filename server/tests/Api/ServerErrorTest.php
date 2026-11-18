<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use Psr\Http\Server\RequestHandlerInterface;
use Wio\App;
use Wio\Auth\DeviceToken;
use Wio\Auth\PasswordHasher;
use Wio\Services;
use Wio\Tests\Support\FrozenClock;

/**
 * An unexpected error is a 500 problem with code `internal`, no details, and
 * a log line without the password, token or body (D-116), plan 005 test T9.
 */
#[Operation('signIn')]
#[Operation('getMe')]
final class ServerErrorTest extends ContractTestCase
{
    private string $log = '';

    protected function app(): RequestHandlerInterface
    {
        return App::create(new Services(
            static fn() => throw new \PDOException('SQLSTATE[HY000] [2002] Duplicate entry \'inhaber@example.org\''),
            new FrozenClock(),
            static fn() => new PasswordHasher(PasswordHasher::LOWEST),
            function (string $line): void {
                $this->log .= $line . "\n";
            },
        ));
    }

    public function testASignInThatFailsInsideIsAnInternalProblem(): void
    {
        $password = 'nie-im-log-' . bin2hex(random_bytes(4));
        $request = $this->request('POST', '/auth/sign-in')
            ->withHeader('Content-Type', 'application/json')
            ->withBody((new \Slim\Psr7\Factory\StreamFactory())->createStream(json_encode(
                ['email' => 'inhaber@example.org', 'password' => $password, 'device_name' => 'Pixel Test'],
                JSON_THROW_ON_ERROR,
            )));

        $response = $this->send($request);

        self::assertSame(500, $response->getStatusCode());
        self::assertSame(
            ['type' => 'about:blank', 'title' => 'Server error', 'status' => 500, 'code' => 'internal'],
            json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR),
        );
        $log = $this->log;
        self::assertStringContainsString('PDOException', $log);
        self::assertStringNotContainsString($password, $log);
        self::assertStringNotContainsString('inhaber@example.org', $log, 'database messages can quote values');
    }

    public function testATokenNeverReachesTheLog(): void
    {
        $token = DeviceToken::generate();

        $response = $this->send($this->request('GET', '/auth/me')->withHeader('Authorization', 'Bearer ' . $token));

        self::assertSame(500, $response->getStatusCode());
        self::assertStringContainsString('PDOException', $this->log);
        self::assertStringNotContainsString($token, $this->log);
    }
}
