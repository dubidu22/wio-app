<?php

declare(strict_types=1);

namespace Wio\Sync;

use Wio\Auth\AuthContext;

/**
 * The rows a caller may read from each synced table (D-182), shared by pull
 * and the file download so the two can never disagree (D-225).
 *
 * - Owners: the whole workspace.
 * - Everyone: their own workspace row and their own user row.
 * - Customers: labels and property keys of the workspace, their own customer
 *   row, and rows of every other table with their customer_id; no conflicts.
 * - Helpers: nothing else until M6.
 */
final class ReadScope
{
    /** Every synced table but these has customer_id and is read by a customer for their own customer only. */
    private const array CUSTOMER_READS_ALL = ['labels', 'property_keys'];

    private function __construct() {}

    /**
     * The scope as an SQL condition on the table's own columns and its
     * values; null when the caller reads nothing from the table.
     *
     * @return array{string, list<string>}|null
     */
    public static function of(AuthContext $caller, string $table): ?array
    {
        $workspace = $table === 'workspaces' ? 'id = ?' : 'workspace_id = ?';
        if ($caller->role === 'owner') {
            return [$workspace, [$caller->workspaceId]];
        }
        if ($table === 'workspaces') {
            return [$workspace, [$caller->workspaceId]];
        }
        if ($table === 'users') {
            return ['workspace_id = ? AND id = ?', [$caller->workspaceId, $caller->userId]];
        }
        if ($caller->role !== 'customer' || $caller->customerId === null || $table === 'conflicts') {
            return null;
        }
        if (\in_array($table, self::CUSTOMER_READS_ALL, true)) {
            return [$workspace, [$caller->workspaceId]];
        }
        if ($table === 'customers') {
            return ['workspace_id = ? AND id = ?', [$caller->workspaceId, $caller->customerId]];
        }
        if (!isset(RecordSchemas::FIELDS[$table]['customer_id'])) {
            return null;
        }

        return ['workspace_id = ? AND customer_id = ?', [$caller->workspaceId, $caller->customerId]];
    }
}
