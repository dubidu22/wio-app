<?php

declare(strict_types=1);

namespace Wio\Sync;

use stdClass;
use Wio\Http\InvalidRequest;

/**
 * One pushed outbox entry (contract schema Change, KB sync.md step 1). The
 * envelope is checked here: a change without a usable change_id or with the
 * wrong shape makes the whole push a 400, because it cannot be answered by
 * change_id. What the change asks for (entity, op, fields) is checked when it
 * is applied and answered per change.
 */
final readonly class Change
{
    public const string UUID = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';

    private const string ENTITY = '/^[a-z][a-z_]{0,31}$/';

    private const array PROPERTIES = ['change_id', 'entity', 'id', 'op', 'fields', 'base_revision', 'device_time'];

    private const int MAX_SAFE_INTEGER = 9007199254740991;

    public function __construct(
        public string $changeId,
        public string $entity,
        public string $id,
        public string $op,
        public stdClass $fields,
        public ?int $baseRevision,
    ) {}

    public static function fromJson(mixed $value, int $index): self
    {
        if (!$value instanceof stdClass) {
            throw new InvalidRequest("changes[{$index}] must be an object.");
        }
        $change = get_object_vars($value);
        foreach (self::PROPERTIES as $property) {
            if (!\array_key_exists($property, $change)) {
                throw new InvalidRequest("changes[{$index}].{$property} is required.");
            }
        }
        if (array_diff(array_keys($change), self::PROPERTIES) !== []) {
            throw new InvalidRequest("changes[{$index}] has an unknown property.");
        }

        // The change_id is answered exactly as sent, so the app finds its
        // outbox entry; the record id is stored in lower case (D-47).
        $changeId = self::uuid($change['change_id'], "changes[{$index}].change_id");
        $id = strtolower(self::uuid($change['id'], "changes[{$index}].id"));
        $entity = $change['entity'];
        if (!\is_string($entity) || preg_match(self::ENTITY, $entity) !== 1) {
            throw new InvalidRequest("changes[{$index}].entity must be a table name.");
        }
        $op = $change['op'];
        if (!\is_string($op) || preg_match(self::ENTITY, $op) !== 1) {
            throw new InvalidRequest("changes[{$index}].op must be an operation name.");
        }
        $fields = $change['fields'];
        if (!$fields instanceof stdClass) {
            throw new InvalidRequest("changes[{$index}].fields must be an object.");
        }
        $base = $change['base_revision'];
        if ($base !== null && (!\is_int($base) || $base < 0 || $base > self::MAX_SAFE_INTEGER)) {
            throw new InvalidRequest("changes[{$index}].base_revision must be null or a revision.");
        }
        if (!\is_string($change['device_time']) || !Fields::isDateTime($change['device_time'])) {
            throw new InvalidRequest("changes[{$index}].device_time must be a date-time.");
        }

        return new self($changeId, $entity, $id, $op, $fields, $base);
    }

    /**
     * SHA-256 of what the change asks for (entity, id, op, fields), with
     * object keys sorted, so a retry of the same change hashes the same and a
     * reused change_id with another payload does not (D-172).
     */
    public function payloadHash(): string
    {
        return hash('sha256', Fields::canonical([
            'entity' => $this->entity,
            'id' => $this->id,
            'op' => $this->op,
            'fields' => $this->fields,
        ]));
    }

    private static function uuid(mixed $value, string $name): string
    {
        if (!\is_string($value) || preg_match(self::UUID, $value) !== 1) {
            throw new InvalidRequest("{$name} must be a UUID.");
        }

        return $value;
    }
}
