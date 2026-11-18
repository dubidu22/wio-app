<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

use PDOException;

/**
 * D-53: every connection runs in UTC with a strict SQL mode.
 */
final class StrictModeTest extends SchemaTestCase
{
    public function testTheConnectionUsesUtcAndAStrictSqlMode(): void
    {
        $row = $this->rowsOf('SELECT @@session.time_zone AS tz, @@session.sql_mode AS mode')[0] ?? [];

        self::assertSame('+00:00', $row['tz'] ?? null);
        $mode = is_string($row['mode'] ?? null) ? explode(',', $row['mode']) : [];
        foreach (['STRICT_ALL_TABLES', 'NO_ZERO_DATE', 'NO_ZERO_IN_DATE', 'ERROR_FOR_DIVISION_BY_ZERO'] as $flag) {
            self::assertContains($flag, $mode);
        }
    }

    public function testAnInvalidDateIsRejectedNotChanged(): void
    {
        $workspace = $this->rows->workspace();
        $customer = $this->rows->customer($workspace);

        $this->expectException(PDOException::class);
        $this->rows->insert('jobs', ['workspace_id' => $workspace, 'customer_id' => $customer, 'date' => '2026-02-30']);
    }

    public function testATooLongNameIsRejectedNotCut(): void
    {
        $workspace = $this->rows->workspace();

        $this->expectException(PDOException::class);
        $this->rows->insert('labels', [
            'workspace_id' => $workspace,
            'name' => str_repeat('x', 101),
            'name_key' => str_repeat('x', 101),
        ]);
    }
}
