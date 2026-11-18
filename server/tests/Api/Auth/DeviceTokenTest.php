<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Auth;

use PHPUnit\Framework\Attributes\DataProvider;
use Wio\Auth\DeviceToken;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;

/**
 * Device tokens and devices (D-110 to D-112), plan 005 tests T6 and T7.
 */
#[Operation('getMe')]
#[Operation('signOut')]
#[Operation('listDevices')]
#[Operation('revokeDevice')]
final class DeviceTokenTest extends DatabaseTestCase
{
    private string $workspace;
    private string $owner;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->fixtures->workspace('Betrieb');
        $this->owner = $this->fixtures->user($this->workspace);
    }

    public function testGetMeNamesTheCaller(): void
    {
        $device = $this->fixtures->token($this->workspace, $this->owner);

        $response = $this->send($this->call('GET', '/auth/me', token: $device['token']));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame([
            'device_id' => $device['device_id'],
            'user' => ['id' => $this->owner, 'role' => 'owner', 'display_name' => 'Inhaber Beispiel'],
            'workspace' => ['id' => $this->workspace, 'name' => 'Betrieb', 'plan' => 'professional'],
        ], self::json($response));
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function unknownTokens(): iterable
    {
        yield 'unknown' => [DeviceToken::generate()];
        yield 'not a wio token' => ['abc'];
        yield 'too long' => ['wio_' . str_repeat('a', 100)];
    }

    #[DataProvider('unknownTokens')]
    public function testAnUnknownTokenIsRefused(string $token): void
    {
        $response = $this->send($this->call('GET', '/auth/me', token: $token));

        self::assertProblem($response, 401, 'token_invalid');
        self::assertSame('Bearer', $response->getHeaderLine('WWW-Authenticate'));
    }

    public function testAMissingTokenIsRefused(): void
    {
        $response = $this->sendInvalid($this->call('GET', '/auth/me'), 'getMe');

        self::assertProblem($response, 401, 'token_invalid');
    }

    public function testATokenIdleFor180DaysIsRefusedAndDeleted(): void
    {
        $device = $this->fixtures->token($this->workspace, $this->owner);

        $this->clock->advance('P179DT23H59M');
        self::assertSame(200, $this->send($this->call('GET', '/auth/me', token: $device['token']))->getStatusCode());

        $this->clock->advance('P180D');
        self::assertProblem($this->send($this->call('GET', '/auth/me', token: $device['token'])), 401, 'token_invalid');
        self::assertSame(0, $this->fixtures->count('device_tokens'));
    }

    public function testLastUsedIsWrittenAtMostOnceAnHour(): void
    {
        $device = $this->fixtures->token($this->workspace, $this->owner);
        $lastUsed = fn(): mixed => $this->sql->run('SELECT last_used_at FROM device_tokens')->fetchColumn();

        $this->clock->advance('PT59M');
        $this->send($this->call('GET', '/auth/me', token: $device['token']));
        self::assertSame('2026-11-18 10:00:00.000', $lastUsed());

        $this->clock->advance('PT1M');
        $this->send($this->call('GET', '/auth/me', token: $device['token']));
        self::assertSame('2026-11-18 11:00:00.000', $lastUsed());
    }

    public function testATokenOfADeletedUserOrWorkspaceIsRefused(): void
    {
        $device = $this->fixtures->token($this->workspace, $this->owner);
        $other = $this->fixtures->workspace('Anderer');
        $otherDevice = $this->fixtures->token($other, $this->fixtures->user($other));

        $this->fixtures->delete('users', $this->owner);
        $this->fixtures->delete('workspaces', $other);

        self::assertProblem($this->send($this->call('GET', '/auth/me', token: $device['token'])), 401, 'token_invalid');
        self::assertProblem($this->send($this->call('GET', '/auth/me', token: $otherDevice['token'])), 401, 'token_invalid');
    }

    public function testAHelperTokenEndsWithTheLink(): void
    {
        $helper = $this->fixtures->user($this->workspace, 'helper', 'helfer@example.org', null, expiresAt: '2026-11-18 12:00:00.000');
        $device = $this->fixtures->token($this->workspace, $helper);

        self::assertSame(200, $this->send($this->call('GET', '/auth/me', token: $device['token']))->getStatusCode());
        $this->clock->advance('PT2H');
        self::assertProblem($this->send($this->call('GET', '/auth/me', token: $device['token'])), 401, 'token_invalid');
    }

    public function testSignOutDeletesTheCallingToken(): void
    {
        $device = $this->fixtures->token($this->workspace, $this->owner);
        $other = $this->fixtures->token($this->workspace, $this->owner, 'Tablet');

        self::assertSame(204, $this->send($this->call('POST', '/auth/sign-out', token: $device['token']))->getStatusCode());

        self::assertProblem($this->send($this->call('GET', '/auth/me', token: $device['token'])), 401, 'token_invalid');
        self::assertSame(200, $this->send($this->call('GET', '/auth/me', token: $other['token']))->getStatusCode());
    }

    public function testListDevicesShowsOnlyTheCallersDevices(): void
    {
        $phone = $this->fixtures->token($this->workspace, $this->owner, 'Telefon');
        $this->clock->advance('PT1M');
        $tablet = $this->fixtures->token($this->workspace, $this->owner, 'Tablet');
        $colleague = $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org', null);
        $this->fixtures->token($this->workspace, $colleague, 'Fremdes Telefon');

        $response = $this->send($this->call('GET', '/auth/devices', token: $phone['token']));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame([
            ['id' => $tablet['device_id'], 'device_name' => 'Tablet', 'created_at' => '2026-11-18T10:01:00.000Z', 'last_used_at' => '2026-11-18T10:01:00.000Z', 'current' => false],
            ['id' => $phone['device_id'], 'device_name' => 'Telefon', 'created_at' => '2026-11-18T10:00:00.000Z', 'last_used_at' => '2026-11-18T10:00:00.000Z', 'current' => true],
        ], self::json($response)['devices']);
    }

    public function testRevokeDeviceSignsOutOneOfTheCallersDevices(): void
    {
        $phone = $this->fixtures->token($this->workspace, $this->owner, 'Telefon');
        $tablet = $this->fixtures->token($this->workspace, $this->owner, 'Tablet');

        $response = $this->send($this->call('DELETE', '/auth/devices/' . $tablet['device_id'], token: $phone['token']));

        self::assertSame(204, $response->getStatusCode());
        self::assertProblem($this->send($this->call('GET', '/auth/me', token: $tablet['token'])), 401, 'token_invalid');
        self::assertSame(204, $this->send($this->call('DELETE', '/auth/devices/' . $phone['device_id'], token: $phone['token']))->getStatusCode());
        self::assertSame(0, $this->fixtures->count('device_tokens'));
    }

    public function testRevokeDeviceDoesNotConfirmOtherDevices(): void
    {
        $phone = $this->fixtures->token($this->workspace, $this->owner);
        $colleague = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org', null));
        $other = $this->fixtures->workspace('Anderer');
        $stranger = $this->fixtures->token($other, $this->fixtures->user($other));

        foreach ([$colleague['device_id'], $stranger['device_id'], '01990000-0000-7000-8000-000000000000'] as $deviceId) {
            self::assertProblem($this->send($this->call('DELETE', '/auth/devices/' . $deviceId, token: $phone['token'])), 404, 'not_found');
        }
        self::assertSame(3, $this->fixtures->count('device_tokens'));
    }
}
