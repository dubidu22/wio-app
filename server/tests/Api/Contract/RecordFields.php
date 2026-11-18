<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

use cebe\openapi\spec\Schema;
use League\OpenAPIValidation\Schema\SchemaValidator;
use Wio\Tests\Api\Contract;

/**
 * Checks the free-form `fields` of a pushed change or a pulled record against
 * the entity's record schema (D-95, D-96, D-97), with the contract's own
 * validator. The server checks pushed fields with its generated copy,
 * src/Sync/RecordSchemas.php (D-177); these tests read the contract itself.
 */
final class RecordFields
{
    /**
     * A pulled record: the whole record, read as a response.
     *
     * @param array<string, mixed> $fields
     */
    public static function checkPulled(string $entity, array $fields): void
    {
        $name = RecordSchemas::BY_TABLE[$entity] ?? null;
        if ($name === null) {
            return; // An entity this version does not know: apps skip it (D-96).
        }
        (new SchemaValidator(SchemaValidator::VALIDATE_AS_RESPONSE))->validate($fields, new Schema(self::inline(Contract::schema($name))));
    }

    /**
     * A pushed change: only writable fields, each optional; the operation
     * decides which fields are allowed at all.
     *
     * @param array<string, mixed> $fields
     */
    public static function checkPushed(string $entity, string $op, array $fields): void
    {
        $name = RecordSchemas::BY_TABLE[$entity] ?? null;
        if ($name === null || \in_array($entity, RecordSchemas::PULL_ONLY, true)) {
            throw new \DomainException("{$entity} cannot be pushed");
        }
        $record = Contract::map(self::inline(Contract::schema($name)));
        $properties = Contract::map($record['properties'] ?? null);

        $allowed = match ($op) {
            'upsert' => array_filter(
                array_keys($properties),
                static fn(string $f): bool => !\in_array($f, RecordSchemas::SERVER_SET, true)
                    && !($entity === 'entries' && \in_array($f, RecordSchemas::PLACE, true)),
            ),
            'move_entry' => $entity === 'entries' ? RecordSchemas::PLACE : [],
            'delete', 'restore' => [],
            default => throw new \DomainException("Unknown op {$op}"),
        };
        if ($op === 'move_entry' && $entity !== 'entries') {
            throw new \DomainException('move_entry is only for entries');
        }

        $writable = [];
        foreach ($allowed as $field) {
            $writable[$field] = $properties[$field];
        }
        $schema = ['type' => 'object', 'additionalProperties' => false, 'properties' => $writable];
        if ($writable === []) {
            $schema['maxProperties'] = 0;
            unset($schema['properties']);
        }
        (new SchemaValidator(SchemaValidator::VALIDATE_AS_REQUEST))->validate($fields, new Schema($schema));
    }

    /**
     * Replaces every local schema $ref by the schema it names, so a schema
     * can be validated on its own.
     *
     * @param array<mixed> $schema
     *
     * @return array<mixed>
     */
    public static function inline(array $schema): array
    {
        $ref = $schema['$ref'] ?? null;
        if (\is_string($ref) && str_starts_with($ref, '#/components/schemas/')) {
            return self::inline(Contract::schema(substr($ref, 21)));
        }
        $out = [];
        foreach ($schema as $key => $value) {
            $out[$key] = \is_array($value) ? self::inline($value) : $value;
        }

        return $out;
    }

    private function __construct() {}
}
