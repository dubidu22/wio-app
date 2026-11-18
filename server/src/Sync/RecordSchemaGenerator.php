<?php

declare(strict_types=1);

namespace Wio\Sync;

use RuntimeException;

/**
 * Turns the record schemas of api/openapi.yaml into the PHP source of
 * RecordSchemas.php (D-177). It takes the parsed contract, so it needs no YAML
 * parser at run time; bin/generate-record-schemas parses the file, and a test
 * proves the committed file equals a fresh generation.
 */
final class RecordSchemaGenerator
{
    /** Which record schema describes which synced table (D-95). */
    public const array SCHEMA_BY_ENTITY = [
        'workspaces' => 'Workspace',
        'users' => 'User',
        'customers' => 'Customer',
        'sites' => 'Site',
        'rooms' => 'Room',
        'openings' => 'Opening',
        'fixtures' => 'Fixture',
        'entries' => 'Entry',
        'place_history' => 'PlaceHistory',
        'pictures' => 'Picture',
        'notes' => 'Note',
        'labels' => 'Label',
        'property_keys' => 'PropertyKey',
        'entity_labels' => 'EntityLabel',
        'entity_properties' => 'EntityProperty',
        'jobs' => 'Job',
        'time_blocks' => 'TimeBlock',
        'sign_offs' => 'SignOff',
        'expenses' => 'Expense',
        'conflicts' => 'Conflict',
    ];

    /** The schema keywords the server checks; everything else (descriptions, examples) is dropped. */
    private const array KEYWORDS = [
        'type', 'format', 'nullable', 'readOnly', 'enum', 'pattern', 'minLength', 'maxLength',
        'minimum', 'maximum', 'items', 'properties', 'required', 'additionalProperties',
    ];

    /** @var array<string, mixed> */
    private array $schemas;

    /**
     * @param array<mixed> $contract api/openapi.yaml, parsed
     */
    public function __construct(array $contract)
    {
        $components = $contract['components'] ?? null;
        $schemas = \is_array($components) ? ($components['schemas'] ?? null) : null;
        if (!\is_array($schemas)) {
            throw new RuntimeException('The contract has no components.schemas.');
        }
        /** @var array<string, mixed> $schemas */
        $this->schemas = $schemas;
    }

    /**
     * entity => field => simplified schema, in contract order.
     *
     * @return array<string, array<string, array<string, mixed>>>
     */
    public function fields(): array
    {
        $out = [];
        foreach (self::SCHEMA_BY_ENTITY as $entity => $name) {
            $record = $this->resolve($this->named($name));
            $properties = $record['properties'] ?? null;
            if (!\is_array($properties)) {
                throw new RuntimeException("Schema {$name} has no properties.");
            }
            foreach ($properties as $field => $schema) {
                if (!\is_array($schema)) {
                    throw new RuntimeException("{$name}.{$field} is not a schema.");
                }
                $out[$entity][(string) $field] = $this->simplify($schema);
            }
        }

        return $out;
    }

    public function source(): string
    {
        $body = '';
        foreach ($this->fields() as $entity => $fields) {
            $body .= '        ' . self::export($entity) . " => [\n";
            foreach ($fields as $field => $schema) {
                $body .= '            ' . self::export($field) . ' => ' . self::exportValue($schema) . ",\n";
            }
            $body .= "        ],\n";
        }

        return <<<PHP
            <?php

            declare(strict_types=1);

            namespace Wio\\Sync;

            /**
             * GENERATED from api/openapi.yaml by bin/generate-record-schemas; do not
             * edit. The record schema of every synced entity (D-95), reduced to the
             * keywords the server checks when it validates pushed fields (D-177).
             * RecordSchemasTest fails when this file differs from a fresh generation.
             */
            final class RecordSchemas
            {
                /** @var array<string, array<string, array<string, mixed>>> entity => field => schema */
                public const array FIELDS = [
            {$body}    ];

                private function __construct() {}
            }

            PHP;
    }

    /**
     * @param array<mixed> $schema
     *
     * @return array<string, mixed>
     */
    private function simplify(array $schema): array
    {
        $schema = $this->resolve($schema);
        $out = [];
        foreach (self::KEYWORDS as $keyword) {
            if (!\array_key_exists($keyword, $schema)) {
                continue;
            }
            $value = $schema[$keyword];
            if ($keyword === 'items' && \is_array($value)) {
                $value = $this->simplify($value);
            } elseif ($keyword === 'properties' && \is_array($value)) {
                $properties = [];
                foreach ($value as $name => $property) {
                    $properties[(string) $name] = \is_array($property) ? $this->simplify($property) : [];
                }
                $value = $properties;
            } elseif ($keyword === 'additionalProperties' && \is_array($value)) {
                $value = $value === [] ? true : $this->simplify($value);
            }
            $out[$keyword] = $value;
        }

        return $out;
    }

    /**
     * Follows a $ref, and merges `allOf` of one schema into the schema that
     * holds it (the contract writes nullable references that way).
     *
     * @param array<mixed> $schema
     *
     * @return array<mixed>
     */
    private function resolve(array $schema): array
    {
        $ref = $schema['$ref'] ?? null;
        if (\is_string($ref)) {
            if (!str_starts_with($ref, '#/components/schemas/')) {
                throw new RuntimeException("Unsupported reference {$ref}.");
            }

            return $this->resolve($this->named(substr($ref, 21)));
        }
        $allOf = $schema['allOf'] ?? null;
        if (\is_array($allOf)) {
            unset($schema['allOf']);
            foreach ($allOf as $part) {
                if (!\is_array($part)) {
                    throw new RuntimeException('allOf holds a non-schema.');
                }
                // The holder's own keywords (nullable) win over the referenced ones.
                $schema += $this->resolve($part);
            }
        }

        return $schema;
    }

    /**
     * @return array<mixed>
     */
    private function named(string $name): array
    {
        $schema = $this->schemas[$name] ?? null;
        if (!\is_array($schema)) {
            throw new RuntimeException("The contract has no schema {$name}.");
        }

        return $schema;
    }

    private static function export(string $value): string
    {
        return "'" . str_replace(['\\', "'"], ['\\\\', "\\'"], $value) . "'";
    }

    private static function exportValue(mixed $value): string
    {
        if (\is_array($value)) {
            $parts = [];
            $list = array_is_list($value);
            foreach ($value as $key => $item) {
                $parts[] = ($list ? '' : self::export((string) $key) . ' => ') . self::exportValue($item);
            }

            return '[' . implode(', ', $parts) . ']';
        }
        if (\is_string($value)) {
            return self::export($value);
        }
        if (\is_bool($value)) {
            return $value ? 'true' : 'false';
        }
        if (\is_int($value)) {
            return (string) $value;
        }
        if ($value === null) {
            return 'null';
        }

        throw new RuntimeException('Cannot export a ' . get_debug_type($value) . '.');
    }
}
