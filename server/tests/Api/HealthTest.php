<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Wio\App;
use Wio\Auth\PasswordHasher;
use Wio\Services;
use Wio\Tests\Support\FrozenClock;

/**
 * GET /health, and the problem+json answers for paths and methods outside
 * the contract (D-116).
 */
#[Operation('getHealth')]
final class HealthTest extends ContractTestCase
{
    /**
     * An app whose database cannot be reached: /health must not need it.
     */
    protected function app(): RequestHandlerInterface
    {
        return App::create(new Services(
            static fn() => throw new \RuntimeException('/health must not open the database'),
            new FrozenClock(),
            static fn() => new PasswordHasher(PasswordHasher::LOWEST),
        ));
    }

    public function testHealthAnswersOkAsJsonWithoutTheDatabase(): void
    {
        $response = $this->send($this->request('GET', '/health'));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('application/json', $response->getHeaderLine('Content-Type'));
        self::assertSame(['status' => 'ok'], json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR));
    }

    public function testUnknownPathIsAProblemNotFound(): void
    {
        $response = $this->sendOutsideContract($this->request('GET', '/no-such-path'));

        self::assertSame(['status' => 404, 'code' => 'not_found'], self::problem($response));
    }

    public function testHealthAcceptsOnlyGet(): void
    {
        $response = $this->sendOutsideContract($this->request('POST', '/health'));

        self::assertSame(['status' => 405, 'code' => 'method_not_allowed'], self::problem($response));
        self::assertSame('GET', $response->getHeaderLine('Allow'));
    }

    /**
     * @return array{status: mixed, code: mixed}
     */
    private static function problem(ResponseInterface $response): array
    {
        self::assertSame('application/problem+json', $response->getHeaderLine('Content-Type'));
        $body = json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR);
        self::assertIsArray($body);
        self::assertSame($response->getStatusCode(), $body['status'] ?? null);
        self::assertSame('about:blank', $body['type'] ?? null);

        return ['status' => $body['status'], 'code' => $body['code'] ?? null];
    }
}
