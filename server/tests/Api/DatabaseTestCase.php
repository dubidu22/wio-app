<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Psr7\Factory\StreamFactory;
use Wio\App;
use Wio\Auth\PasswordHasher;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Services;
use Wio\Tests\Support\AuthFixtures;
use Wio\Tests\Support\FrozenClock;
use Wio\Tests\Support\MigratedDatabase;

/**
 * An API test against a migrated MariaDB, with a frozen clock and the lowest
 * password cost (D-120). Tables are emptied before every test.
 */
abstract class DatabaseTestCase extends ContractTestCase
{
    protected const string IP = '192.0.2.10';

    protected FrozenClock $clock;
    protected Sql $sql;
    protected AuthFixtures $fixtures;

    /** @var list<string> lines the app logged, instead of PHP's error log */
    protected array $logged = [];

    /** The server's minimum app version in this test (D-145). */
    protected ?string $minimumAppVersion = null;

    /** The server's WIO_CORS_ORIGINS in this test (D-164). */
    protected string $corsOrigins = '';

    public static function setUpBeforeClass(): void
    {
        MigratedDatabase::migrate();
    }

    public static function tearDownAfterClass(): void
    {
        MigratedDatabase::drop();
    }

    protected function setUp(): void
    {
        $this->clock = new FrozenClock();
        $this->sql = new Sql(Connection::fromEnvironment());
        MigratedDatabase::empty($this->sql->pdo);
        $this->fixtures = new AuthFixtures($this->sql, $this->clock);
    }

    protected function services(): Services
    {
        $pdo = $this->sql->pdo;

        return new Services(
            static fn() => $pdo,
            $this->clock,
            static fn() => new PasswordHasher(PasswordHasher::LOWEST),
            function (string $line): void {
                $this->logged[] = $line;
            },
            $this->minimumAppVersion,
            $this->corsOrigins,
        );
    }

    protected function app(): RequestHandlerInterface
    {
        return App::create($this->services());
    }

    /**
     * @param array<string, mixed>|null $body
     */
    protected function call(string $method, string $uri, ?array $body = null, ?string $token = null, string $ip = self::IP, ?string $appVersion = null): ServerRequestInterface
    {
        $request = $this->request($method, $uri, ['REMOTE_ADDR' => $ip]);
        if ($body !== null) {
            $request = $request
                ->withHeader('Content-Type', 'application/json')
                ->withBody((new StreamFactory())->createStream(json_encode($body, JSON_THROW_ON_ERROR)));
        }
        if ($token !== null) {
            $request = $request->withHeader('Authorization', 'Bearer ' . $token);
        }
        if ($appVersion !== null) {
            $request = $request->withHeader('Wio-App-Version', $appVersion);
        }

        return $request;
    }

    /**
     * @return array<string, mixed>
     */
    protected static function json(ResponseInterface $response): array
    {
        $body = json_decode((string) $response->getBody(), true, 16, JSON_THROW_ON_ERROR);
        self::assertIsArray($body);

        /** @var array<string, mixed> */
        return $body;
    }

    /**
     * A valid sign-in body.
     *
     * @return array<string, string>
     */
    protected static function credentials(string $email = 'inhaber@example.org', string $password = AuthFixtures::PASSWORD): array
    {
        return ['email' => $email, 'password' => $password, 'device_name' => 'Pixel Test'];
    }

    /**
     * @param array<string, mixed> $body
     */
    protected function signIn(array $body, string $ip = self::IP): ResponseInterface
    {
        return $this->send($this->call('POST', '/auth/sign-in', $body, ip: $ip));
    }

    protected static function assertProblem(ResponseInterface $response, int $status, string $code): void
    {
        self::assertSame($status, $response->getStatusCode(), (string) $response->getBody());
        self::assertStringStartsWith('application/problem+json', $response->getHeaderLine('Content-Type'));
        self::assertSame($code, self::json($response)['code'] ?? null);
    }
}
