<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use Symfony\Component\Yaml\Yaml;

/**
 * Read access to api/openapi.yaml and api/examples/ for the contract tests.
 */
final class Contract
{
    public const string FILE = __DIR__ . '/../../../api/openapi.yaml';

    public const string EXAMPLES = __DIR__ . '/../../../api/examples';

    public const int MAX_SAFE_INTEGER = 9007199254740991;

    /** @var array<string, mixed>|null */
    private static ?array $document = null;

    /**
     * The contract as plain arrays, parsed once per run.
     *
     * @return array<string, mixed>
     */
    public static function document(): array
    {
        if (self::$document === null) {
            $parsed = Yaml::parseFile(self::FILE);
            if (!\is_array($parsed)) {
                throw new \RuntimeException('api/openapi.yaml is not a mapping');
            }
            /** @var array<string, mixed> $parsed */
            self::$document = $parsed;
        }

        return self::$document;
    }

    /**
     * Every operation as "METHOD /path" => operationId.
     *
     * @return array<string, string>
     */
    public static function operations(): array
    {
        $operations = [];
        foreach (self::map(self::document()['paths'] ?? null) as $path => $item) {
            foreach (self::map($item) as $method => $operation) {
                $operationId = self::map($operation)['operationId'] ?? null;
                if (\is_string($operationId)) {
                    $operations[strtoupper($method) . ' ' . $path] = $operationId;
                }
            }
        }

        return $operations;
    }

    /**
     * @return array<string, mixed>
     */
    public static function schemas(): array
    {
        return self::map(self::map(self::document()['components'] ?? null)['schemas'] ?? null);
    }

    /**
     * @return array<string, mixed>
     */
    public static function schema(string $name): array
    {
        $schema = self::schemas()[$name] ?? null;
        if (!\is_array($schema)) {
            throw new \RuntimeException("No schema {$name} in the contract");
        }

        /** @var array<string, mixed> $schema */
        return $schema;
    }

    public static function text(mixed $value): string
    {
        if (!\is_string($value)) {
            throw new \UnexpectedValueException('Expected a string, got ' . get_debug_type($value));
        }

        return $value;
    }

    /**
     * @return array<string, mixed>
     */
    public static function map(mixed $value): array
    {
        if (!\is_array($value)) {
            return [];
        }
        $map = [];
        foreach ($value as $key => $item) {
            $map[(string) $key] = $item;
        }

        return $map;
    }

    private function __construct() {}
}
