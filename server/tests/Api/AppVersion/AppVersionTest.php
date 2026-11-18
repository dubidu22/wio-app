<?php

declare(strict_types=1);

namespace Wio\Tests\Api\AppVersion;

use PHPUnit\Framework\Attributes\DataProvider;
use Psr\Http\Message\ServerRequestInterface;
use Wio\App;
use Wio\Auth\PasswordHasher;
use Wio\Services;
use Wio\Tests\Api\Contract;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;
use Wio\Tests\Support\AuthFixtures;

/**
 * The app-version check on every operation (D-140 to D-144), plan 033 tests
 * T2 to T5.
 */
#[Operation('getHealth')]
#[Operation('signIn')]
#[Operation('signOut')]
#[Operation('getMe')]
#[Operation('listDevices')]
#[Operation('revokeDevice')]
#[Operation('syncPush')]
#[Operation('syncPull')]
final class AppVersionTest extends DatabaseTestCase
{
    private const string OLD = '1.9.9+40';

    private int $hashersBuilt = 0;

    protected function setUp(): void
    {
        parent::setUp();
        $this->minimumAppVersion = '2.0.0';
    }

    protected function services(): Services
    {
        $pdo = $this->sql->pdo;

        return new Services(
            static fn() => $pdo,
            $this->clock,
            function (): PasswordHasher {
                ++$this->hashersBuilt;

                return new PasswordHasher(PasswordHasher::LOWEST);
            },
            function (string $line): void {
                $this->logged[] = $line;
            },
            $this->minimumAppVersion,
        );
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function operations(): iterable
    {
        foreach (self::OPERATIONS as $operation) {
            yield $operation => [$operation];
        }
    }

    private const array OPERATIONS = ['getHealth', 'signIn', 'signOut', 'getMe', 'listDevices', 'revokeDevice', 'syncPush', 'syncPull'];

    #[DataProvider('operations')]
    public function testAnOldAppGets426OnEveryOperation(string $operation): void
    {
        $response = $this->send($this->requestFor($operation, self::OLD));

        self::assertProblem($response, 426, 'upgrade_required');
        self::assertSame('2.0.0', self::json($response)['minimum_app_version'] ?? null);
    }

    public function testEveryRoutedOperationIsChecked(): void
    {
        $operations = Contract::operations();
        $routed = [];
        foreach (App::create($this->services())->getRouteCollector()->getRoutes() as $route) {
            foreach ($route->getMethods() as $method) {
                $routed[] = $operations[strtoupper($method) . ' ' . $route->getPattern()] ?? '?';
            }
        }
        sort($routed);
        $listed = self::OPERATIONS;
        sort($listed);

        self::assertSame($routed, $listed, 'add the new operation to OPERATIONS and requestFor()');
    }

    public function testAnOldAppLearnsToUpdateBeforeItsTokenIsChecked(): void
    {
        self::assertProblem($this->send($this->call('GET', '/auth/me', token: 'wio_' . str_repeat('A', 43), appVersion: self::OLD)), 426, 'upgrade_required');
    }

    public function testAnOldAppsSignInChecksNoPasswordAndRecordsNoFailure(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        self::assertProblem($this->send($this->call('POST', '/auth/sign-in', self::credentials(password: 'falsch'), appVersion: self::OLD)), 426, 'upgrade_required');
        self::assertProblem($this->send($this->call('POST', '/auth/sign-in', self::credentials(), appVersion: self::OLD)), 426, 'upgrade_required');

        self::assertSame(0, $this->hashersBuilt, 'no password check for an old app');
        self::assertSame(0, $this->fixtures->count('sign_in_failures'));
        self::assertSame(0, $this->fixtures->count('device_tokens'));
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function currentVersions(): iterable
    {
        yield 'the minimum' => ['2.0.0'];
        yield 'the minimum with a build' => ['2.0.0+1'];
        yield 'a newer patch' => ['2.0.1'];
        yield 'a newer minor' => ['2.1.0'];
        yield 'compared as numbers, not text' => ['10.0.0'];
        yield 'leading zeros' => ['02.0.0'];
    }

    #[DataProvider('currentVersions')]
    public function testACurrentAppGoesThrough(string $version): void
    {
        $workspace = $this->fixtures->workspace();
        $device = $this->fixtures->token($workspace, $this->fixtures->user($workspace));

        self::assertSame(200, $this->send($this->call('GET', '/health', appVersion: $version))->getStatusCode());
        self::assertSame(200, $this->send($this->call('GET', '/auth/me', token: $device['token'], appVersion: $version))->getStatusCode());
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function belowTheMinimum(): iterable
    {
        yield 'an older major' => ['1.99.99'];
        yield 'an older patch with a newer build' => ['1.9.9+999999999'];
        yield 'zero' => ['0.0.0'];
    }

    #[DataProvider('belowTheMinimum')]
    public function testBelowTheMinimum(string $version): void
    {
        self::assertProblem($this->send($this->call('GET', '/health', appVersion: $version)), 426, 'upgrade_required');
    }

    public function testMinorAndPatchCount(): void
    {
        $this->minimumAppVersion = '2.3.4';

        self::assertProblem($this->send($this->call('GET', '/health', appVersion: '2.3.3')), 426, 'upgrade_required');
        self::assertProblem($this->send($this->call('GET', '/health', appVersion: '2.2.9')), 426, 'upgrade_required');
        self::assertProblem($this->send($this->call('GET', '/health', appVersion: '2.3.3+999')), 426, 'upgrade_required');
        self::assertSame(200, $this->send($this->call('GET', '/health', appVersion: '2.3.4'))->getStatusCode());
        self::assertSame(200, $this->send($this->call('GET', '/health', appVersion: '2.4.0'))->getStatusCode());
    }

    public function testNoHeaderGoesThrough(): void
    {
        self::assertSame(200, $this->send($this->call('GET', '/health'))->getStatusCode());
        $this->fixtures->user($this->fixtures->workspace());
        self::assertSame(200, $this->send($this->call('POST', '/auth/sign-in', self::credentials()))->getStatusCode());
    }

    public function testWithoutAMinimumEveryVersionGoesThrough(): void
    {
        $this->minimumAppVersion = null;

        self::assertSame(200, $this->send($this->call('GET', '/health', appVersion: '0.0.1'))->getStatusCode());
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function malformed(): iterable
    {
        yield 'two parts' => ['1.2'];
        yield 'a pre-release' => ['1.2.3-beta'];
        yield 'a prefix' => ['v1.2.3'];
        yield 'over 32 characters' => ['123456789.123456789.123456789+123'];
        yield 'a part of 10 digits' => ['1234567890.0.0'];
        yield 'a build that is not a number' => ['1.2.3+abc'];
        yield 'empty' => [''];
    }

    #[DataProvider('malformed')]
    public function testAMalformedHeaderIsABadRequest(string $version): void
    {
        foreach (['2.0.0', null] as $minimum) {
            $this->minimumAppVersion = $minimum;
            $response = $this->sendInvalid($this->call('GET', '/health', appVersion: $version), 'getHealth');

            self::assertProblem($response, 400, 'invalid_request');
            $detail = self::json($response)['detail'] ?? null;
            self::assertIsString($detail);
            self::assertStringContainsString('Wio-App-Version', $detail);
            if ($version !== '') {
                self::assertStringNotContainsString($version, $detail, 'the detail never repeats the value');
            }
        }
    }

    private function requestFor(string $operation, string $appVersion): ServerRequestInterface
    {
        $workspace = $this->fixtures->workspace();
        $device = $this->fixtures->token($workspace, $this->fixtures->user($workspace));
        $token = $device['token'];

        return match ($operation) {
            'getHealth' => $this->call('GET', '/health', appVersion: $appVersion),
            'signIn' => $this->call('POST', '/auth/sign-in', self::credentials('inhaber@example.org', AuthFixtures::PASSWORD), appVersion: $appVersion),
            'signOut' => $this->call('POST', '/auth/sign-out', token: $token, appVersion: $appVersion),
            'getMe' => $this->call('GET', '/auth/me', token: $token, appVersion: $appVersion),
            'listDevices' => $this->call('GET', '/auth/devices', token: $token, appVersion: $appVersion),
            'revokeDevice' => $this->call('DELETE', '/auth/devices/' . $device['device_id'], token: $token, appVersion: $appVersion),
            'syncPush' => $this->call('POST', '/sync/push', ['changes' => [[
                'change_id' => '01990000-0000-7000-8000-00000000c001',
                'entity' => 'labels',
                'id' => '01990000-0000-7000-8000-00000000a001',
                'op' => 'upsert',
                'fields' => ['name' => 'Keller'],
                'base_revision' => null,
                'device_time' => '2026-11-18T09:00:00.000Z',
            ]]], token: $token, appVersion: $appVersion),
            'syncPull' => $this->call('GET', '/sync/pull?since=0', token: $token, appVersion: $appVersion),
            default => self::fail("No request for {$operation}"),
        };
    }
}
