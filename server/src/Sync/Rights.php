<?php

declare(strict_types=1);

namespace Wio\Sync;

use Wio\Auth\AuthContext;

/**
 * What each role may push (D-181), in one place. KB data-model.md, rights per
 * role (D-13); the permission matrix and RightsTest check every cell.
 *
 * - Owners: every synced entity except place_history (written only by
 *   move_entry), users (user management is M6), the read-only
 *   workspaces.plan, and conflicts, which they may only delete (dismiss).
 * - Customers, only within their own customer: create pictures and notes,
 *   and edit, delete or restore the ones they created themselves; add,
 *   remove and restore labels on entries.
 * - Helpers: nothing until M6 defines what a helper link grants (D-182).
 */
final class Rights
{
    private const array CHANGE = ['upsert', 'delete', 'restore'];

    /** @var array<string, array<string, list<string>>> role => entity => ops */
    public const array OPS = [
        'owner' => [
            'workspaces' => ['upsert'],
            'customers' => self::CHANGE,
            'sites' => self::CHANGE,
            'rooms' => self::CHANGE,
            'openings' => self::CHANGE,
            'fixtures' => self::CHANGE,
            'entries' => ['upsert', 'delete', 'restore', 'move_entry'],
            'pictures' => self::CHANGE,
            'notes' => self::CHANGE,
            'labels' => self::CHANGE,
            'property_keys' => self::CHANGE,
            'entity_labels' => self::CHANGE,
            'entity_properties' => self::CHANGE,
            'jobs' => self::CHANGE,
            'time_blocks' => self::CHANGE,
            'sign_offs' => self::CHANGE,
            'expenses' => self::CHANGE,
            'conflicts' => ['delete'],
        ],
        'customer' => [
            'pictures' => self::CHANGE,
            'notes' => self::CHANGE,
            'entity_labels' => self::CHANGE,
        ],
        'helper' => [],
    ];

    /** Fields no role may push, although the entity is allowed. */
    public const array READ_ONLY = ['workspaces' => ['plan']];

    /** Entities a customer may change only where they created the record. */
    private const array OWN_RECORDS = ['pictures', 'notes'];

    private function __construct() {}

    /**
     * The first check: may this role do this op on this entity at all.
     */
    public static function mayPush(AuthContext $caller, string $entity, string $op): bool
    {
        return \in_array($op, self::OPS[$caller->role][$entity] ?? [], true);
    }

    /**
     * The record check, once the record and its customer are known.
     *
     * @param array<string, mixed>|null $stored the record before the change; null when it is new
     * @param ?string $customerId the record's customer after the change
     * @param list<string> $fields the pushed field names
     */
    public static function mayChange(
        AuthContext $caller,
        string $entity,
        string $op,
        ?array $stored,
        ?string $customerId,
        array $fields,
        ?string $entityType,
    ): bool {
        if (array_intersect($fields, self::READ_ONLY[$entity] ?? []) !== []) {
            return false;
        }
        if ($entity === 'workspaces') {
            // Only the caller's own workspace; never a new one.
            return $stored !== null && $stored['id'] === $caller->workspaceId;
        }
        if ($caller->role === 'owner') {
            return true;
        }
        if ($caller->role !== 'customer' || $caller->customerId === null || $customerId !== $caller->customerId) {
            return false;
        }
        if ($stored !== null && ($stored['customer_id'] ?? null) !== $caller->customerId) {
            return false;
        }
        if (\in_array($entity, self::OWN_RECORDS, true)) {
            return $stored === null || ($stored['created_by'] ?? null) === $caller->userId;
        }
        if ($entity === 'entity_labels') {
            // Add (never edit) a label link, or remove and restore one, on entries only.
            return $entityType === 'entry' && ($op !== 'upsert' || $stored === null);
        }

        return false;
    }
}
