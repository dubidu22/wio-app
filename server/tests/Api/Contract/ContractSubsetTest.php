<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\Tests\Api\Contract;

/**
 * The contract stays in the subset that means the same in OpenAPI 3.0 and 3.1
 * (D-89, D-90) and follows the evolution rules of D-99.
 */
final class ContractSubsetTest extends TestCase
{
    public function testTheContractIsOpenApi303(): void
    {
        self::assertSame('3.0.3', Contract::document()['openapi'] ?? null);
    }

    public function testNoRefHasSiblings(): void
    {
        foreach ($this->nodes() as $path => $node) {
            if (\array_key_exists('$ref', $node)) {
                self::assertSame(['$ref'], array_keys($node), "{$path}: a \$ref must stand alone (D-90); use allOf");
            }
        }
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function bannedKeys(): iterable
    {
        yield 'boolean exclusive bounds' => ['exclusiveMinimum'];
        yield 'boolean exclusive bounds, max' => ['exclusiveMaximum'];
        yield 'schema example' => ['example'];
        yield 'const' => ['const'];
    }

    #[DataProvider('bannedKeys')]
    public function testKeyIsNotUsed(string $key): void
    {
        foreach ($this->nodes() as $path => $node) {
            self::assertArrayNotHasKey($key, $node, "{$path}: {$key} is outside the version-neutral subset (D-90)");
        }
    }

    public function testNoExtensions(): void
    {
        foreach ($this->nodes() as $path => $node) {
            foreach (array_keys($node) as $key) {
                self::assertDoesNotMatchRegularExpression('/^x-/', "{$key}", "{$path}: no x- extensions (D-90)");
            }
        }
    }

    public function testNullableAlwaysHasAType(): void
    {
        foreach ($this->nodes() as $path => $node) {
            if (($node['nullable'] ?? false) === true) {
                self::assertArrayHasKey('type', $node, "{$path}: nullable needs a type beside it (D-90)");
            }
        }
    }

    public function testGrowingIntegersStayBelowTwoToThe53(): void
    {
        foreach ($this->nodes() as $path => $node) {
            if (($node['type'] ?? null) === 'integer' && ($node['format'] ?? null) === 'int64') {
                self::assertSame(Contract::MAX_SAFE_INTEGER, $node['maximum'] ?? null, "{$path}: int64 needs maximum 2^53-1 for Dart on the web (D-99)");
            }
        }
    }

    public function testEveryOperationEndsWithTheSharedProblemDefault(): void
    {
        foreach (Contract::map(Contract::document()['paths'] ?? null) as $path => $item) {
            foreach (Contract::map($item) as $method => $operation) {
                $default = Contract::map(Contract::map(Contract::map($operation)['responses'] ?? null)['default'] ?? null);
                self::assertSame(
                    ['$ref' => '#/components/responses/Problem'],
                    $default,
                    "{$method} {$path}: needs default: \$ref '#/components/responses/Problem' so any status keeps its code (D-98)",
                );
            }
        }
    }

    public function testEveryOperationTakesTheAppVersionHeaderAndLists426(): void
    {
        foreach (Contract::map(Contract::document()['paths'] ?? null) as $path => $item) {
            foreach (Contract::map($item) as $method => $operation) {
                $operation = Contract::map($operation);
                $parameters = \is_array($operation['parameters'] ?? null) ? $operation['parameters'] : [];
                self::assertContains(
                    ['$ref' => '#/components/parameters/WioAppVersion'],
                    $parameters,
                    "{$method} {$path}: needs the Wio-App-Version header parameter (D-140)",
                );
                $upgrade = null;
                foreach (Contract::map($operation['responses'] ?? null) as $status => $response) {
                    if ("{$status}" === '426') {
                        $upgrade = $response;
                    }
                }
                self::assertSame(
                    ['$ref' => '#/components/responses/UpgradeRequired'],
                    $upgrade,
                    "{$method} {$path}: needs '426': \$ref '#/components/responses/UpgradeRequired' (D-146)",
                );
            }
        }
    }

    public function testRequestSchemasAreClosedAndResponseSchemasOpen(): void
    {
        $requests = $this->reachable($this->bodySchemaRefs('requestBody'));
        $responses = $this->reachable($this->bodySchemaRefs('responses'));
        self::assertNotEmpty($requests);

        foreach (Contract::schemas() as $name => $schema) {
            $schema = Contract::map($schema);
            if (!\array_key_exists('properties', $schema)) {
                continue;
            }
            $closed = ($schema['additionalProperties'] ?? true) === false;
            if (\in_array($name, $requests, true) && !\in_array($name, $responses, true)) {
                self::assertTrue($closed, "Request schema {$name} must set additionalProperties: false (D-99)");
            } else {
                self::assertFalse($closed, "Schema {$name} is read by apps and must stay open (D-99)");
            }
        }
    }

    /**
     * Every mapping in the document with its JSON pointer.
     *
     * @return iterable<string, array<string, mixed>>
     */
    private function nodes(): iterable
    {
        $stack = [['#', Contract::document()]];
        while ($stack !== []) {
            [$path, $node] = array_pop($stack);
            if (!\is_array($node)) {
                continue;
            }
            if (array_is_list($node)) {
                foreach ($node as $i => $child) {
                    $stack[] = ["{$path}/{$i}", $child];
                }
                continue;
            }
            $map = Contract::map($node);
            yield $path => $map;
            foreach ($map as $key => $child) {
                if (\is_array($child)) {
                    $stack[] = ["{$path}/{$key}", $child];
                }
            }
        }
    }

    /**
     * Names of component schemas referenced inside request bodies or
     * responses of operations.
     *
     * @return list<string>
     */
    private function bodySchemaRefs(string $part): array
    {
        $refs = [];
        foreach (Contract::map(Contract::document()['paths'] ?? null) as $item) {
            foreach (Contract::map($item) as $operation) {
                $body = Contract::map($operation)[$part] ?? null;
                if ($part === 'responses') {
                    $responses = [];
                    foreach (Contract::map($body) as $response) {
                        $responses[] = $this->resolveResponse(Contract::map($response));
                    }
                    $body = $responses;
                }
                array_push($refs, ...$this->refsIn($body));
            }
        }

        return array_values(array_unique($refs));
    }

    /**
     * @param array<string, mixed> $response
     *
     * @return array<string, mixed>
     */
    private function resolveResponse(array $response): array
    {
        $ref = $response['$ref'] ?? null;
        if (\is_string($ref) && str_starts_with($ref, '#/components/responses/')) {
            $components = Contract::map(Contract::document()['components'] ?? null);

            return Contract::map(Contract::map($components['responses'] ?? null)[substr($ref, 23)] ?? null);
        }

        return $response;
    }

    /**
     * @param list<string> $names
     *
     * @return list<string>
     */
    private function reachable(array $names): array
    {
        $seen = [];
        while ($names !== []) {
            $name = array_pop($names);
            if (\in_array($name, $seen, true)) {
                continue;
            }
            $seen[] = $name;
            array_push($names, ...$this->refsIn(Contract::schemas()[$name] ?? null));
        }

        return $seen;
    }

    /**
     * @return list<string>
     */
    private function refsIn(mixed $node): array
    {
        $refs = [];
        if (!\is_array($node)) {
            return $refs;
        }
        foreach ($node as $key => $child) {
            if ($key === '$ref' && \is_string($child) && str_starts_with($child, '#/components/schemas/')) {
                $refs[] = substr($child, 21);
            } else {
                array_push($refs, ...$this->refsIn($child));
            }
        }

        return $refs;
    }
}
