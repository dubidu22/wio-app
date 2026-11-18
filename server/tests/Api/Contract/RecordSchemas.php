<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

/**
 * Which record schema of the contract describes which synced table (D-95),
 * and the column rules shared by the contract tests.
 */
final class RecordSchemas
{
    /** @var array<string, string> table => schema */
    public const array BY_TABLE = [
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

    /** Tables that never sync. */
    public const array SERVER_TABLES = ['schema_migrations', 'workspace_counters'];

    /** Columns the server derives and never sends (D-49, D-51). */
    public const array SERVER_COLUMNS = ['alive', 'no_customer', 'name_key', 'email_key'];

    /** Columns only the server sets; read-only in the contract. */
    public const array SERVER_SET = ['id', 'workspace_id', 'created_at', 'created_by', 'updated_at', 'updated_by', 'revision', 'deleted_at'];

    /** The current place of an entry, changed only by move_entry (D-97). */
    public const array PLACE = ['site_id', 'room_id', 'fixture_id', 'level', 'compartment', 'floor_x_cm', 'floor_y_cm'];

    /** Entities apps may only pull in M1 (D-96). */
    public const array PULL_ONLY = ['workspaces', 'users', 'place_history', 'conflicts'];

    private function __construct() {}
}
