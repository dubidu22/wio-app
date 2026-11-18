<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

/**
 * D-48, D-49: within a professional workspace, a record of one customer can
 * never point at a record of another customer.
 */
final class CustomerScopeTest extends SchemaTestCase
{
    private string $workspace;
    private string $anna;
    private string $ben;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->rows->workspace();
        $this->anna = $this->rows->customer($this->workspace);
        $this->ben = $this->rows->customer($this->workspace);
    }

    public function testARoomCannotBeOnAnotherCustomersSite(): void
    {
        $bensSite = $this->rows->site($this->workspace, $this->ben);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->room($this->workspace, $bensSite, $this->anna));
    }

    public function testAnEntryCannotBePlacedAtAnotherCustomersSite(): void
    {
        $bensSite = $this->rows->site($this->workspace, $this->ben);
        $bensRoom = $this->rows->room($this->workspace, $bensSite, $this->ben);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->entry($this->workspace, $this->anna, [
            'site_id' => $bensSite,
            'room_id' => $bensRoom,
        ]));
    }

    public function testAnEntryCannotTargetAnotherCustomersSite(): void
    {
        $bensSite = $this->rows->site($this->workspace, $this->ben);
        $bensRoom = $this->rows->room($this->workspace, $bensSite, $this->ben);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->entry($this->workspace, $this->anna, [
            'target_site_id' => $bensSite,
            'target_room_id' => $bensRoom,
        ]));
    }

    public function testAnEntryCanBePlacedAtItsOwnCustomersSite(): void
    {
        $site = $this->rows->site($this->workspace, $this->anna);
        $room = $this->rows->room($this->workspace, $site, $this->anna);

        self::assertNotSame('', $this->rows->entry($this->workspace, $this->anna, [
            'site_id' => $site,
            'room_id' => $room,
        ]));
    }

    public function testAnAfterPictureCannotFollowAnotherCustomersPicture(): void
    {
        $bensPicture = $this->rows->picture($this->workspace, $this->ben);

        $this->assertRejected(
            self::FOREIGN_KEY,
            fn() => $this->rows->picture($this->workspace, $this->anna, ['after_of' => $bensPicture]),
        );
    }

    public function testAnExpenseCannotUseAnotherCustomersReceipt(): void
    {
        $annasJob = $this->rows->job($this->workspace, $this->anna);
        $bensPicture = $this->rows->picture($this->workspace, $this->ben);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->insert('expenses', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->anna,
            'job_id' => $annasJob,
            'picture_id' => $bensPicture,
        ]));
    }

    public function testATimeBlockCannotBeBookedOnAnotherCustomersJob(): void
    {
        $bensJob = $this->rows->job($this->workspace, $this->ben);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->insert('time_blocks', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->anna,
            'job_id' => $bensJob,
            'started_at' => '2026-01-05 09:00:00',
        ]));
    }

    public function testPlaceHistoryCannotBeWrittenForAnotherCustomersEntry(): void
    {
        $bensEntry = $this->rows->entry($this->workspace, $this->ben);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->insert('place_history', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->anna,
            'entry_id' => $bensEntry,
            'moved_at' => '2026-01-05 09:00:00',
        ]));
    }

    public function testAPersonalWorkspaceNeedsNoCustomer(): void
    {
        $personal = $this->rows->workspace('personal');
        $site = $this->rows->site($personal, null);
        $room = $this->rows->room($personal, $site, null);
        $fixture = $this->rows->fixture($personal, $room, null);

        self::assertNotSame('', $this->rows->entry($personal, null, [
            'site_id' => $site,
            'room_id' => $room,
            'fixture_id' => $fixture,
            'level' => 1,
        ]));
    }
}
