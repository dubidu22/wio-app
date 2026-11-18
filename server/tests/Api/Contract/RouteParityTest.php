<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

use PHPUnit\Framework\TestCase;
use Wio\App;
use Wio\Tests\Api\Contract;
use Wio\Tests\Api\ContractTestCase;
use Wio\Tests\Api\Operation;

/**
 * Routes and contract agree (D-94): every route is an operation, every
 * operation is routed or on the pending list, and every routed operation is
 * called by at least one contract-validated test.
 */
final class RouteParityTest extends TestCase
{
    private const string PENDING = __DIR__ . '/../pending-operations.php';

    public function testEveryRouteIsAnOperationOfTheContract(): void
    {
        $operations = Contract::operations();
        foreach ($this->routes() as $route) {
            self::assertArrayHasKey($route, $operations, "Route {$route} is not in api/openapi.yaml");
        }
    }

    public function testEveryOperationIsRoutedOrPending(): void
    {
        $routes = $this->routes();
        $pending = $this->pending();
        foreach (Contract::operations() as $route => $operationId) {
            $routed = \in_array($route, $routes, true);
            $listed = \array_key_exists($operationId, $pending);
            self::assertTrue($routed || $listed, "{$operationId} ({$route}) is neither routed nor in pending-operations.php");
            self::assertFalse($routed && $listed, "{$operationId} is routed now: remove it from pending-operations.php");
        }
    }

    public function testThePendingListNamesOnlyOperationsOfTheContract(): void
    {
        $operationIds = array_values(Contract::operations());
        foreach ($this->pending() as $operationId => $issue) {
            self::assertContains($operationId, $operationIds, "pending-operations.php lists unknown {$operationId}");
            self::assertGreaterThan(0, $issue);
        }
    }

    public function testEveryRoutedOperationHasATest(): void
    {
        $tested = $this->testedOperations();
        $operations = Contract::operations();
        foreach ($this->routes() as $route) {
            $operationId = $operations[$route] ?? $route;
            self::assertContains($operationId, $tested, "No test declares #[Operation('{$operationId}')]");
        }
    }

    /**
     * @return list<string> "METHOD /pattern"
     */
    private function routes(): array
    {
        $routes = [];
        foreach (App::create()->getRouteCollector()->getRoutes() as $route) {
            foreach ($route->getMethods() as $method) {
                $routes[] = strtoupper($method) . ' ' . $route->getPattern();
            }
        }

        return $routes;
    }

    /**
     * @return array<string, int>
     */
    private function pending(): array
    {
        /** @var array<string, int> $pending */
        $pending = require self::PENDING;

        return $pending;
    }

    /**
     * operationIds declared by #[Operation] on contract tests under tests/Api,
     * except the harness test, which calls /health only to prove it can fail.
     *
     * @return list<string>
     */
    private function testedOperations(): array
    {
        $root = \dirname(__DIR__);
        $declared = [];
        $files = new \RecursiveIteratorIterator(new \RecursiveDirectoryIterator($root, \FilesystemIterator::SKIP_DOTS));
        foreach ($files as $file) {
            if (!$file instanceof \SplFileInfo || $file->getExtension() !== 'php') {
                continue;
            }
            $relative = substr($file->getPathname(), \strlen($root) + 1, -4);
            $class = 'Wio\\Tests\\Api\\' . str_replace('/', '\\', $relative);
            if ($class === ContractHarnessTest::class || !class_exists($class) || !is_subclass_of($class, ContractTestCase::class)) {
                continue;
            }
            $reflection = new \ReflectionClass($class);
            if ($reflection->isAbstract()) {
                continue;
            }
            $holders = [$reflection, ...$reflection->getMethods()];
            foreach ($holders as $holder) {
                foreach ($holder->getAttributes(Operation::class) as $attribute) {
                    $declared[] = $attribute->newInstance()->operationId;
                }
            }
        }

        return array_values(array_unique($declared));
    }
}
