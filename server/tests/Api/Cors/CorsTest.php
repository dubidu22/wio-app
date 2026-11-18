<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Cors;

use PHPUnit\Framework\Attributes\DataProvider;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\SignInLimiter;
use Wio\Http\Cors;
use Wio\Tests\Api\Contract;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;

/**
 * CORS for a web app on its own origin (D-164 to D-171), plan 010 addendum
 * tests K1 to K5 and K8.
 */
#[Operation('getHealth')]
#[Operation('signIn')]
#[Operation('getMe')]
final class CorsTest extends DatabaseTestCase
{
    private const string WEB = 'https://app.example.org';

    protected function setUp(): void
    {
        parent::setUp();
        $this->corsOrigins = self::WEB . ', http://localhost:8080';
    }

    public function testAPreflightFromAListedOriginGetsTheAllowList(): void
    {
        $response = $this->sendOutsideContract($this->preflight('/auth/me', self::WEB));

        self::assertSame(204, $response->getStatusCode());
        self::assertSame(self::WEB, $response->getHeaderLine('Access-Control-Allow-Origin'));
        self::assertSame('GET, POST, PUT, DELETE', $response->getHeaderLine('Access-Control-Allow-Methods'));
        self::assertSame('Authorization, Content-Type, Content-Range, Wio-App-Version', $response->getHeaderLine('Access-Control-Allow-Headers'));
        self::assertSame('600', $response->getHeaderLine('Access-Control-Max-Age'));
        self::assertSame('Origin', $response->getHeaderLine('Vary'));
        self::assertFalse($response->hasHeader('Access-Control-Allow-Credentials'));
        self::assertSame('', (string) $response->getBody());
    }

    public function testLocalhostWithAPortIsAllowedWhenListed(): void
    {
        $response = $this->sendOutsideContract($this->preflight('/health', 'http://localhost:8080'));

        self::assertSame('http://localhost:8080', $response->getHeaderLine('Access-Control-Allow-Origin'));
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function foreignOrigins(): iterable
    {
        yield 'another site' => ['https://example.org'];
        yield 'null' => ['null'];
        yield 'a look-alike that starts with the listed origin' => ['https://app.example.org.evil.test'];
        yield 'a subdomain of the listed origin' => ['https://x.app.example.org'];
        yield 'http instead of https' => ['http://app.example.org'];
        yield 'another port' => ['https://app.example.org:8443'];
        yield 'localhost on another port' => ['http://localhost:8081'];
    }

    #[DataProvider('foreignOrigins')]
    public function testAPreflightFromAForeignOriginGetsNoCorsHeaders(string $origin): void
    {
        $response = $this->sendOutsideContract($this->preflight('/auth/me', $origin));

        self::assertSame(204, $response->getStatusCode());
        self::assertNoCorsHeaders($response);
    }

    #[DataProvider('foreignOrigins')]
    public function testAnAnswerToAForeignOriginHasNoCorsHeaders(string $origin): void
    {
        $response = $this->send($this->call('GET', '/health')->withHeader('Origin', $origin));

        self::assertSame(200, $response->getStatusCode());
        self::assertNoCorsHeaders($response);
        self::assertSame('Origin', $response->getHeaderLine('Vary'));
    }

    public function testAPreflightNeverReachesTheVersionCheckOrAuth(): void
    {
        $this->minimumAppVersion = '2.0.0';

        $response = $this->sendOutsideContract($this->preflight('/auth/devices/01990000-0000-7000-8000-000000000000', self::WEB, 'DELETE')
            ->withHeader('Wio-App-Version', '1.0.0'));

        self::assertSame(204, $response->getStatusCode());
        self::assertSame(self::WEB, $response->getHeaderLine('Access-Control-Allow-Origin'));
    }

    public function testASuccessCarriesTheHeaders(): void
    {
        self::assertCors($this->send($this->call('GET', '/health')->withHeader('Origin', self::WEB)), 200);
    }

    public function testAMissingTokenCarriesTheHeaders(): void
    {
        $response = $this->sendInvalid($this->call('GET', '/auth/me')->withHeader('Origin', self::WEB), 'getMe');

        self::assertCors($response, 401);
        self::assertProblem($response, 401, 'token_invalid');
    }

    public function testAnUnknownPathCarriesTheHeaders(): void
    {
        $response = $this->sendOutsideContract($this->call('GET', '/nirgends')->withHeader('Origin', self::WEB));

        self::assertCors($response, 404);
        self::assertSame('not_found', self::json($response)['code'] ?? null);
    }

    public function testAnOldAppCarriesTheHeaders(): void
    {
        $this->minimumAppVersion = '2.0.0';

        $response = $this->send($this->call('GET', '/health', appVersion: '1.0.0')->withHeader('Origin', self::WEB));

        self::assertCors($response, 426);
        self::assertProblem($response, 426, 'upgrade_required');
    }

    public function testTheSignInLimitCarriesTheHeadersAndExposesRetryAfter(): void
    {
        $limiter = new SignInLimiter($this->sql, $this->clock);
        for ($i = 0; $i < SignInLimiter::PER_EMAIL; ++$i) {
            $limiter->reserve(SignInLimiter::emailHash('inhaber@example.org'), SignInLimiter::ipHash("192.0.2.{$i}"));
        }

        $response = $this->send($this->call('POST', '/auth/sign-in', self::credentials())->withHeader('Origin', self::WEB));

        self::assertCors($response, 429);
        self::assertSame('900', $response->getHeaderLine('Retry-After'));
        self::assertSame('Retry-After', $response->getHeaderLine('Access-Control-Expose-Headers'));
    }

    public function testAServerErrorCarriesTheHeaders(): void
    {
        // A missing table makes sign-in fail inside, as a 500.
        $this->sql->run('RENAME TABLE sign_in_failures TO sign_in_failures_away');
        try {
            $response = $this->send($this->call('POST', '/auth/sign-in', self::credentials())->withHeader('Origin', self::WEB));
        } finally {
            $this->sql->run('RENAME TABLE sign_in_failures_away TO sign_in_failures');
        }

        self::assertCors($response, 500);
        self::assertSame('internal', self::json($response)['code'] ?? null);
    }

    public function testWithoutAnOriginThereAreNoCorsHeaders(): void
    {
        $response = $this->send($this->call('GET', '/health'));

        self::assertNoCorsHeaders($response);
        self::assertFalse($response->hasHeader('Vary'));
    }

    public function testWithoutConfigNoOriginGetsCorsHeaders(): void
    {
        $this->corsOrigins = '';

        self::assertNoCorsHeaders($this->send($this->call('GET', '/health')->withHeader('Origin', self::WEB)));
        self::assertNoCorsHeaders($this->sendOutsideContract($this->preflight('/health', self::WEB)));
    }

    public function testAnOriginListedInAForbiddenFormIsLoggedAndGetsNoHeaders(): void
    {
        $this->corsOrigins = 'https://app.example.org/';

        self::assertNoCorsHeaders($this->send($this->call('GET', '/health')->withHeader('Origin', 'https://app.example.org/')));
        self::assertCount(1, $this->logged);
        self::assertStringNotContainsString('example.org', $this->logged[0], 'the log line names no origin');
    }

    public function testTheMethodsAreTheContractsMethods(): void
    {
        $methods = [];
        foreach (Contract::map(Contract::document()['paths'] ?? null) as $item) {
            foreach (array_keys(Contract::map($item)) as $method) {
                $methods[] = strtoupper("{$method}");
            }
        }
        $methods = array_values(array_unique($methods));
        sort($methods);
        $listed = Cors::METHODS;
        sort($listed);

        self::assertSame($methods, $listed);
    }

    private function preflight(string $path, string $origin, string $method = 'GET'): ServerRequestInterface
    {
        return $this->request('OPTIONS', $path, ['REMOTE_ADDR' => self::IP])
            ->withHeader('Origin', $origin)
            ->withHeader('Access-Control-Request-Method', $method)
            ->withHeader('Access-Control-Request-Headers', 'authorization,wio-app-version');
    }

    private static function assertCors(ResponseInterface $response, int $status): void
    {
        self::assertSame($status, $response->getStatusCode(), (string) $response->getBody());
        self::assertSame(self::WEB, $response->getHeaderLine('Access-Control-Allow-Origin'));
        self::assertSame('Retry-After', $response->getHeaderLine('Access-Control-Expose-Headers'));
        self::assertContains('Origin', array_map('trim', explode(',', $response->getHeaderLine('Vary'))));
        self::assertFalse($response->hasHeader('Access-Control-Allow-Credentials'));
    }

    private static function assertNoCorsHeaders(ResponseInterface $response): void
    {
        foreach (array_keys($response->getHeaders()) as $name) {
            self::assertStringStartsNotWith('access-control-', strtolower((string) $name), "{$name} must not be sent");
        }
    }
}
