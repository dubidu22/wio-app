<?php

declare(strict_types=1);

namespace Wio\Sync;

/**
 * How synced tables hang together, for push: where a record's customer_id
 * comes from (D-178), which subject a link or note points to (D-180), and
 * which unique keys mean "a live record already holds this value" (D-179).
 * Table names in SQL come only from these constants and RecordSchemas.
 */
final class Entities
{
    /**
     * Children take customer_id from the first parent that is set, in this
     * order. Entries and pictures without a parent take it from `fields`.
     *
     * @var array<string, list<array{string, string}>> entity => [column, parent table]
     */
    public const array PARENTS = [
        'rooms' => [['site_id', 'sites']],
        'openings' => [['room_id', 'rooms']],
        'fixtures' => [['room_id', 'rooms']],
        'entries' => [['site_id', 'sites']],
        'pictures' => [['room_id', 'rooms'], ['entry_id', 'entries']],
        'time_blocks' => [['job_id', 'jobs']],
        'sign_offs' => [['job_id', 'jobs']],
        'expenses' => [['job_id', 'jobs']],
    ];

    /** Entities whose parent is optional: without one, customer_id comes from `fields`. */
    public const array PARENT_OPTIONAL = ['entries', 'pictures'];

    /**
     * Links and notes point to a subject the database cannot check (D-50).
     *
     * @var array<string, array{string, string, array<string, string>}> entity => [type column, id column, type => table]
     */
    public const array SUBJECTS = [
        'entity_labels' => ['entity_type', 'entity_id', ['entry' => 'entries', 'room' => 'rooms', 'fixture' => 'fixtures', 'picture' => 'pictures']],
        'entity_properties' => ['entity_type', 'entity_id', ['entry' => 'entries', 'room' => 'rooms', 'fixture' => 'fixtures', 'picture' => 'pictures']],
        'notes' => ['subject_type', 'subject_id', ['entry' => 'entries', 'room' => 'rooms', 'picture' => 'pictures', 'job' => 'jobs', 'customer' => 'customers']],
    ];

    /**
     * Unique keys of live records (D-51): a clash is `duplicate` with the id
     * of the live record (D-179).
     *
     * @var array<string, list<string>> key name => columns besides workspace_id
     */
    public const array LIVE_UNIQUE = [
        'uq_labels_name' => ['name_key'],
        'uq_property_keys_name' => ['name_key'],
        'uq_entries_code' => ['code'],
        'uq_customers_external_ref' => ['external_ref'],
        'uq_entity_labels_link' => ['entity_type', 'entity_id', 'label_id'],
        'uq_entity_properties_link' => ['entity_type', 'entity_id', 'key_id'],
    ];

    /** Entities with a name that gets a server-made name_key (D-51). */
    public const array NAME_KEYED = ['labels', 'property_keys'];

    private function __construct() {}

    /**
     * Whether the table has a customer_id column the server keeps right.
     */
    public static function hasCustomer(string $entity): bool
    {
        return isset(RecordSchemas::FIELDS[$entity]['customer_id']) && $entity !== 'users';
    }

    /**
     * Whether customer_id is a pushed value (top-level records) rather than
     * one derived from a parent or subject.
     */
    public static function customerFromFields(string $entity): bool
    {
        return self::hasCustomer($entity) && !isset(self::PARENTS[$entity]) && !isset(self::SUBJECTS[$entity]);
    }
}
