<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Permission;

use Wio\App;
use Wio\Tests\Api\Contract;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;

/**
 * The auth middleware covers exactly the operations the contract secures
 * (D-112), plan 005 test T10: every other routed operation answers a request
 * without a token with 401 token_invalid, and the public ones do not.
 */
#[Operation('getHealth')]
#[Operation('signIn')]
#[Operation('signOut')]
#[Operation('getMe')]
#[Operation('listDevices')]
#[Operation('revokeDevice')]
#[Operation('syncPush')]
#[Operation('syncPull')]
final class AuthCoverageTest extends DatabaseTestCase
{
    /**
     * The operations with `security: []` in the contract.
     *
     * @return list<string>
     */
    public static function publicOperations(): array
    {
        $public = [];
        foreach (Contract::map(Contract::document()['paths'] ?? null) as $path) {
            foreach (Contract::map($path) as $operation) {
                $operation = Contract::map($operation);
                if (\array_key_exists('security', $operation) && $operation['security'] === []) {
                    $public[] = Contract::text($operation['operationId'] ?? null);
                }
            }
        }
        sort($public);

        return $public;
    }

    public function testThePublicOperationsAreHealthAndSignIn(): void
    {
        self::assertSame(['getHealth', 'signIn'], self::publicOperations());
    }

    public function testEveryOtherRoutedOperationNeedsAToken(): void
    {
        $operations = Contract::operations();
        $checked = 0;
        foreach (App::create($this->services())->getRouteCollector()->getRoutes() as $route) {
            foreach ($route->getMethods() as $method) {
                $operation = $operations[strtoupper($method) . ' ' . $route->getPattern()] ?? null;
                self::assertIsString($operation);
                $path = (string) preg_replace('/\{[^}]+\}/', '01990000-0000-7000-8000-000000000000', $route->getPattern());
                $request = $this->call($method, $path, $method === 'POST' ? [] : null);

                $response = $this->sendInvalidOrValid($request, $operation);

                if (\in_array($operation, self::publicOperations(), true)) {
                    self::assertNotSame(401, $response->getStatusCode(), "{$operation} is public");
                } else {
                    self::assertProblem($response, 401, 'token_invalid');
                }
                ++$checked;
            }
        }
        self::assertGreaterThanOrEqual(6, $checked);
    }

    /**
     * A request without a token breaks the contract for a secured operation
     * and for a POST without its body; /health without a token is valid.
     */
    private function sendInvalidOrValid(\Psr\Http\Message\ServerRequestInterface $request, string $operation): \Psr\Http\Message\ResponseInterface
    {
        return $operation === 'getHealth' ? $this->send($request) : $this->sendInvalid($request, $operation);
    }
}
