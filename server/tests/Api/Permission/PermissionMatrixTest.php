<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Permission;

use PHPUnit\Framework\Attributes\DataProvider;
use Psr\Http\Message\ServerRequestInterface;
use Wio\App;
use Wio\Tests\Api\Contract;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;
use Wio\Tests\Support\AuthFixtures;

/**
 * Every cell of matrix.php (D-117), plan 005 test T11.
 */
#[Operation('getHealth')]
#[Operation('signIn')]
#[Operation('signOut')]
#[Operation('getMe')]
#[Operation('listDevices')]
#[Operation('revokeDevice')]
#[Operation('syncPush')]
#[Operation('syncPull')]
#[Operation('getFileState')]
#[Operation('putFileChunk')]
final class PermissionMatrixTest extends DatabaseTestCase
{
    /**
     * @return array<string, array<string, int|string>>
     */
    private static function matrix(): array
    {
        /** @var array<string, array<string, int|string>> */
        return require __DIR__ . '/matrix.php';
    }

    /**
     * @return iterable<string, array{string, string, int|string}>
     */
    public static function cells(): iterable
    {
        foreach (self::matrix() as $operation => $row) {
            foreach ($row as $caller => $status) {
                yield "{$operation} as {$caller}" => [$operation, $caller, $status];
            }
        }
    }

    #[DataProvider('cells')]
    public function testCell(string $operation, string $caller, int|string $expected): void
    {
        $workspace = $this->fixtures->workspace();
        $emails = [
            'owner' => 'inhaber@example.org',
            'customer' => 'kunde@example.org',
            'helper' => 'helfer@example.org',
            'expired_helper' => 'alter-helfer@example.org',
        ];
        $device = null;
        $target = null;
        if ($caller === 'other_workspace') {
            $target = $this->fixtures->token($workspace, $this->fixtures->user($workspace));
            $workspace = $this->fixtures->workspace('Anderer Betrieb');
            $emails['other_workspace'] = 'andere@example.org';
        }
        if ($caller !== 'anonymous') {
            $role = match ($caller) {
                'expired_helper' => 'helper',
                'other_workspace' => 'owner',
                default => $caller,
            };
            $expires = $caller === 'expired_helper' ? '2026-11-18 09:00:00.000' : null;
            $user = $this->fixtures->user($workspace, $role, $emails[$caller], expiresAt: $expires);
            $device = $this->fixtures->token($workspace, $user);
        }

        $result = str_ends_with($operation, ' result');
        $operation = $result ? substr($operation, 0, -7) : $operation;
        $request = $this->requestFor($operation, $emails[$caller] ?? 'niemand@example.org', $device, $target['device_id'] ?? null);
        $response = $device === null && $this->isSecured($operation)
            ? $this->sendInvalid($request, $operation)
            : $this->send($request);

        if (\is_int($expected)) {
            self::assertSame($expected, $response->getStatusCode(), (string) $response->getBody());
        } else {
            self::assertSame(200, $response->getStatusCode(), (string) $response->getBody());
            $results = self::json($response)['results'] ?? null;
            self::assertIsArray($results);
            $first = $results[0] ?? null;
            self::assertIsArray($first);
            self::assertSame($expected, $first['status'] === 'rejected' ? $first['reason'] : $first['status'], (string) $response->getBody());
        }
        if ($target !== null) {
            self::assertNotNull(
                $this->sql->row('SELECT id FROM device_tokens WHERE id = ?', [$target['device_id']]),
                'another workspace never touches the first workspace\'s device',
            );
        }
    }

    public function testEveryRoutedOperationHasARow(): void
    {
        $operations = Contract::operations();
        $routed = [];
        foreach (App::create($this->services())->getRouteCollector()->getRoutes() as $route) {
            foreach ($route->getMethods() as $method) {
                $routed[] = $operations[strtoupper($method) . ' ' . $route->getPattern()] ?? '?';
            }
        }
        sort($routed);
        $rows = array_values(array_filter(array_keys(self::matrix()), static fn(string $row): bool => !str_ends_with($row, ' result')));
        sort($rows);

        self::assertSame($routed, $rows, 'matrix.php needs one row per routed operation');
        foreach (self::matrix() as $operation => $row) {
            self::assertSame(['anonymous', 'owner', 'customer', 'helper', 'expired_helper', 'other_workspace'], array_keys($row), $operation);
        }
    }

    /**
     * @param array{token: string, device_id: string}|null $device
     * @param string|null $targetDevice a device of another workspace to revoke
     */
    private function requestFor(string $operation, string $email, ?array $device, ?string $targetDevice): ServerRequestInterface
    {
        $token = $device['token'] ?? null;

        return match ($operation) {
            'getHealth' => $this->call('GET', '/health', token: $token),
            'signIn' => $this->call('POST', '/auth/sign-in', self::credentials($email, AuthFixtures::PASSWORD)),
            'signOut' => $this->call('POST', '/auth/sign-out', token: $token),
            'getMe' => $this->call('GET', '/auth/me', token: $token),
            'listDevices' => $this->call('GET', '/auth/devices', token: $token),
            'revokeDevice' => $this->call('DELETE', '/auth/devices/' . ($targetDevice ?? $device['device_id'] ?? '01990000-0000-7000-8000-000000000000'), token: $token),
            'syncPush' => $this->call('POST', '/sync/push', ['changes' => [[
                'change_id' => '01990000-0000-7000-8000-00000000c001',
                'entity' => 'labels',
                'id' => '01990000-0000-7000-8000-00000000a001',
                'op' => 'upsert',
                'fields' => ['name' => 'Keller'],
                'base_revision' => null,
                'device_time' => '2026-11-18T09:00:00.000Z',
            ]]], token: $token),
            'syncPull' => $this->call('GET', '/sync/pull?since=0', token: $token),
            'getFileState' => $this->call('GET', '/files/' . hash('sha256', 'Kiste') . '/state', token: $token),
            'putFileChunk' => $this->chunk(hash('sha256', 'Kiste'), 'Kiste', 0, 5, $token),
            default => self::fail("No request for {$operation}: add it here and a row to matrix.php"),
        };
    }

    private function isSecured(string $operation): bool
    {
        return !\in_array($operation, AuthCoverageTest::publicOperations(), true);
    }
}
