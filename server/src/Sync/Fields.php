<?php

declare(strict_types=1);

namespace Wio\Sync;

use DateTimeImmutable;
use stdClass;
use Wio\Support\Time;

/**
 * The fields of synced records: which ones a change may carry, their check
 * against the record schema (D-177), and the conversion between the
 * contract's JSON values and database columns. JSON objects are kept as
 * stdClass, so `{}` and `[]` stay apart.
 */
final class Fields
{
    /** Columns only the server sets (readOnly in the contract). */
    public const array SERVER_SET = ['id', 'workspace_id', 'created_at', 'created_by', 'updated_at', 'updated_by', 'revision', 'deleted_at'];

    /** Columns the server derives and never sends or accepts (D-49, D-51). */
    public const array SERVER_COLUMNS = ['alive', 'no_customer', 'name_key', 'email_key'];

    /** An entry's current place: changed only by move_entry (D-176). */
    public const array PLACE = ['site_id', 'room_id', 'fixture_id', 'level', 'compartment', 'floor_x_cm', 'floor_y_cm'];

    private const string DATE_TIME = '/^(\d{4})-(\d{2})-(\d{2})[Tt](\d{2}):(\d{2}):(\d{2})(\.\d{1,6})?([Zz]|[+-]\d{2}:\d{2})$/';

    /** The contract's decimal-as-text pattern (entity_properties.value_number, a DECIMAL(20,6) column). */
    public const string DECIMAL_PATTERN = '^-?[0-9]{1,14}(\\.[0-9]{1,6})?$';

    private const string DATE = '/^(\d{4})-(\d{2})-(\d{2})$/';

    private const string UUID = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';

    private function __construct() {}

    /**
     * Checks the fields of a change for its entity and op and returns them as
     * field => JSON value. Read-only, server-made, unknown and (for upsert
     * on entries) place fields are refused. move_entry always gets all seven
     * place fields: one it leaves out is null, because a place is one value.
     *
     * @return array<string, mixed>
     *
     * @throws Rejected
     */
    public static function check(string $entity, string $op, stdClass $fields): array
    {
        $schemas = RecordSchemas::FIELDS[$entity];
        $given = get_object_vars($fields);
        $allowed = match ($op) {
            'upsert' => array_values(array_filter(
                array_keys($schemas),
                static fn(string $field): bool => !self::readOnly($schemas[$field])
                    && !\in_array($field, self::SERVER_SET, true)
                    && !($entity === 'entries' && \in_array($field, self::PLACE, true)),
            )),
            'move_entry' => self::PLACE,
            default => [],
        };

        $out = [];
        foreach ($given as $field => $value) {
            $field = (string) $field;
            if (!\in_array($field, $allowed, true)) {
                throw Rejected::invalid(self::name($field) . ' cannot be pushed with ' . $op . '.');
            }
            self::validate($schemas[$field], $value, $field);
            $out[$field] = $value;
        }
        if ($op === 'move_entry') {
            foreach (self::PLACE as $field) {
                $out[$field] ??= null;
            }
        }

        return $out;
    }

    /**
     * @param array<string, mixed> $schema
     *
     * @throws Rejected
     */
    public static function validate(array $schema, mixed $value, string $path): void
    {
        if ($value === null) {
            if ($schema !== [] && ($schema['nullable'] ?? false) !== true) {
                throw Rejected::invalid("{$path} must not be null.");
            }

            return;
        }
        $type = $schema['type'] ?? null;
        $ok = match ($type) {
            'string' => \is_string($value) && self::validString($schema, $value),
            'integer' => \is_int($value) && self::validNumber($schema, $value),
            'number' => (\is_int($value) || \is_float($value)) && self::validNumber($schema, $value),
            'boolean' => \is_bool($value),
            'array' => \is_array($value) && array_is_list($value),
            'object' => $value instanceof stdClass,
            null => true,
            default => false,
        };
        if (!$ok) {
            throw Rejected::invalid("{$path} does not match its schema.");
        }
        if (\is_array($value) && \is_array($schema['items'] ?? null)) {
            /** @var array<string, mixed> $items */
            $items = $schema['items'];
            foreach ($value as $i => $item) {
                self::validate($items, $item, "{$path}[{$i}]");
            }
        }
        if ($value instanceof stdClass) {
            self::validateObject($schema, $value, $path);
        }
    }

    /**
     * The value to bind for a column, from a checked JSON value.
     *
     * @param array<string, mixed> $schema
     */
    public static function toDatabase(array $schema, mixed $value): string|int|null
    {
        if ($value === null) {
            return null;
        }
        if (self::isJson($schema)) {
            return json_encode($value, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION);
        }
        if (\is_bool($value)) {
            return $value ? 1 : 0;
        }
        if (($schema['format'] ?? null) === 'date-time' && \is_string($value)) {
            return Time::toDatabase(new DateTimeImmutable($value));
        }
        if (($schema['format'] ?? null) === 'uuid' && \is_string($value)) {
            return strtolower($value); // Ids are stored in lower case (D-47).
        }
        if (\is_int($value) || \is_string($value)) {
            return $value;
        }
        if (\is_float($value)) {
            return (string) $value;
        }

        throw new \LogicException('A checked value has no column form.');
    }

    /**
     * The contract's JSON value of a column.
     *
     * @param array<string, mixed> $schema
     */
    public static function fromDatabase(array $schema, mixed $value): mixed
    {
        if ($value === null) {
            return null;
        }
        if (self::isJson($schema)) {
            return json_decode(\is_string($value) ? $value : '', false, 512, JSON_THROW_ON_ERROR);
        }
        $type = $schema['type'] ?? null;
        if ($type === 'integer') {
            return is_numeric($value) ? (int) $value : throw new \UnexpectedValueException('Not an integer column.');
        }
        if (($schema['format'] ?? null) === 'date-time') {
            return Time::toJson(Time::fromDatabase(\is_string($value) ? $value : ''));
        }

        if (!\is_scalar($value)) {
            throw new \UnexpectedValueException('Not a text column.');
        }
        $text = (string) $value;
        if (($schema['pattern'] ?? null) === self::DECIMAL_PATTERN && str_contains($text, '.')) {
            // DECIMAL(20,6) pads to six places; the app gets back what it sent.
            $text = rtrim(rtrim($text, '0'), '.');
        }

        return $text;
    }

    /**
     * A value as JSON with object keys sorted, for hashing and comparing.
     */
    public static function canonical(mixed $value): string
    {
        return json_encode(self::sorted($value), JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_PRESERVE_ZERO_FRACTION);
    }

    public static function isDateTime(string $value): bool
    {
        if (preg_match(self::DATE_TIME, $value, $m) !== 1) {
            return false;
        }
        if (!checkdate((int) $m[2], (int) $m[3], (int) $m[1]) || (int) $m[4] > 23 || (int) $m[5] > 59 || (int) $m[6] > 59) {
            return false;
        }
        $offset = $m[8];
        if (\strlen($offset) === 6 && ((int) substr($offset, 1, 2) > 23 || (int) substr($offset, 4, 2) > 59)) {
            return false;
        }
        // DATETIME(3) holds years 1000 to 9999 only.
        return (int) $m[1] >= 1000;
    }

    /**
     * @param array<string, mixed> $schema
     */
    public static function isJson(array $schema): bool
    {
        $type = $schema['type'] ?? null;

        return $type === null || $type === 'object' || $type === 'array';
    }

    /**
     * @param array<string, mixed> $schema
     */
    public static function readOnly(array $schema): bool
    {
        return ($schema['readOnly'] ?? false) === true;
    }

    /**
     * A field name for a detail: only a plain identifier is echoed, never an
     * arbitrary submitted string.
     */
    public static function name(string $field): string
    {
        return preg_match('/^[a-z][a-z0-9_]{0,63}$/', $field) === 1 ? $field : 'a field';
    }

    /**
     * @param array<string, mixed> $schema
     */
    private static function validString(array $schema, string $value): bool
    {
        if (!mb_check_encoding($value, 'UTF-8')) {
            return false;
        }
        $enum = $schema['enum'] ?? null;
        if (\is_array($enum) && !\in_array($value, $enum, true)) {
            return false;
        }
        $length = mb_strlen($value, 'UTF-8');
        $max = $schema['maxLength'] ?? null;
        $min = $schema['minLength'] ?? null;
        if ((\is_int($max) && $length > $max) || (\is_int($min) && $length < $min)) {
            return false;
        }
        $pattern = $schema['pattern'] ?? null;
        if (\is_string($pattern) && preg_match('~' . str_replace('~', '\~', $pattern) . '~u', $value) !== 1) {
            return false;
        }

        return match ($schema['format'] ?? null) {
            'uuid' => preg_match(self::UUID, $value) === 1,
            'date-time' => self::isDateTime($value),
            'date' => preg_match(self::DATE, $value, $m) === 1 && checkdate((int) $m[2], (int) $m[3], (int) $m[1]) && (int) $m[1] >= 1000,
            default => true,
        };
    }

    /**
     * @param array<string, mixed> $schema
     */
    private static function validNumber(array $schema, int|float $value): bool
    {
        $min = $schema['minimum'] ?? null;
        $max = $schema['maximum'] ?? null;
        if (((\is_int($min) || \is_float($min)) && $value < $min) || ((\is_int($max) || \is_float($max)) && $value > $max)) {
            return false;
        }

        return match ($schema['format'] ?? null) {
            'int32' => $value >= -2147483648 && $value <= 2147483647,
            'int64' => $value >= -9007199254740991 && $value <= 9007199254740991,
            default => true,
        };
    }

    /**
     * @param array<string, mixed> $schema
     *
     * @throws Rejected
     */
    private static function validateObject(array $schema, stdClass $value, string $path): void
    {
        $given = get_object_vars($value);
        $required = $schema['required'] ?? [];
        foreach (\is_array($required) ? $required : [] as $name) {
            if (\is_string($name) && !\array_key_exists($name, $given)) {
                throw Rejected::invalid("{$path}.{$name} is required.");
            }
        }
        $properties = \is_array($schema['properties'] ?? null) ? $schema['properties'] : [];
        foreach ($given as $name => $item) {
            $name = (string) $name;
            $property = $properties[$name] ?? null;
            if (\is_array($property)) {
                /** @var array<string, mixed> $property */
                self::validate($property, $item, "{$path}." . self::name($name));
            } elseif (($schema['additionalProperties'] ?? true) === false) {
                throw Rejected::invalid("{$path} has an unknown property.");
            }
        }
    }

    private static function sorted(mixed $value): mixed
    {
        if ($value instanceof stdClass) {
            $value = get_object_vars($value);
            ksort($value, SORT_STRING);
            $out = new stdClass();
            foreach ($value as $key => $item) {
                $out->{$key} = self::sorted($item);
            }

            return $out;
        }
        if (\is_array($value)) {
            if (!array_is_list($value)) {
                ksort($value, SORT_STRING);
            }

            return array_map(self::sorted(...), $value);
        }

        return $value;
    }
}
