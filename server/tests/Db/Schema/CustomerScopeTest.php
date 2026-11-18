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

    /**
     * A child without a customer must not hang under a parent that has one,
     * or it would drop out of every customer-scoped read and pull (review
     * round 1, M1). InnoDB skips a foreign key with a null column, so the
     * no_customer flag carries this check.
     */
    public function testAChildCannotDropTheCustomerOfItsParent(): void
    {
        $site = $this->rows->site($this->workspace, $this->anna);
        $room = $this->rows->room($this->workspace, $site, $this->anna);
        $entry = $this->rows->entry($this->workspace, $this->anna, ['site_id' => $site, 'room_id' => $room]);
        $picture = $this->rows->picture($this->workspace, $this->anna);
        $roomData = ['workspace_id' => $this->workspace, 'customer_id' => null, 'room_id' => $room];

        $cases = [
            'room on site' => fn() => $this->rows->room($this->workspace, $site, null),
            'opening in room' => fn() => $this->rows->insert('openings', $roomData + [
                'kind' => 'door',
                'wall_index' => 0,
                'offset_cm' => 10,
                'width_cm' => 80,
            ]),
            'fixture in room' => fn() => $this->rows->fixture($this->workspace, $room, null),
            'entry at site' => fn() => $this->rows->entry($this->workspace, null, ['site_id' => $site, 'room_id' => $room]),
            'entry targeting site' => fn() => $this->rows->entry($this->workspace, null, [
                'target_site_id' => $site,
                'target_room_id' => $room,
            ]),
            'history of entry' => fn() => $this->rows->insert('place_history', [
                'workspace_id' => $this->workspace,
                'entry_id' => $entry,
                'moved_at' => '2026-01-05 09:00:00',
            ]),
            'history to site' => fn() => $this->rows->insert('place_history', [
                'workspace_id' => $this->workspace,
                'entry_id' => $this->rows->entry($this->workspace, null),
                'to_site_id' => $site,
                'to_room_id' => $room,
                'moved_at' => '2026-01-05 09:00:00',
            ]),
            'picture of room' => fn() => $this->rows->picture($this->workspace, null, ['room_id' => $room]),
            'picture of entry' => fn() => $this->rows->picture($this->workspace, null, ['entry_id' => $entry]),
            'after picture' => fn() => $this->rows->picture($this->workspace, null, ['after_of' => $picture]),
        ];

        foreach ($cases as $case => $write) {
            $this->pdo->exec('SAVEPOINT child_case');
            try {
                $this->assertRejected(self::FOREIGN_KEY, $write);
            } catch (\Throwable $e) {
                throw new \RuntimeException("Case '{$case}': " . $e->getMessage(), 0, $e);
            }
            $this->pdo->exec('ROLLBACK TO SAVEPOINT child_case');
        }
    }

    public function testAnUpdateCannotDropTheCustomerOfAChild(): void
    {
        $site = $this->rows->site($this->workspace, $this->anna);
        $room = $this->rows->room($this->workspace, $site, $this->anna);

        $this->assertRejected(self::FOREIGN_KEY, function () use ($room): void {
            $statement = $this->pdo->prepare('UPDATE rooms SET customer_id = NULL WHERE id = ?');
            self::assertNotFalse($statement);
            $statement->execute([$room]);
        });
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
