<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

/**
 * D-49: a record can never point at a record of another workspace.
 */
final class WorkspaceIsolationTest extends SchemaTestCase
{
    public function testARoomCannotUseASiteOfAnotherWorkspace(): void
    {
        $mine = $this->rows->workspace('personal');
        $theirSite = $this->rows->site($this->rows->workspace('personal'), null);

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->room($mine, $theirSite, null));
    }

    public function testARoomCanUseASiteOfItsOwnWorkspace(): void
    {
        $mine = $this->rows->workspace('personal');
        $site = $this->rows->site($mine, null);

        self::assertNotSame('', $this->rows->room($mine, $site, null));
    }

    public function testALabelLinkCannotUseALabelOfAnotherWorkspace(): void
    {
        $mine = $this->rows->workspace('personal');
        $entry = $this->rows->entry($mine, null);
        $theirLabel = $this->rows->label($this->rows->workspace('personal'), 'Keller');

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->insert('entity_labels', [
            'workspace_id' => $mine,
            'entity_type' => 'entry',
            'entity_id' => $entry,
            'label_id' => $theirLabel,
        ]));
    }

    public function testATimeBlockCannotUseAJobOfAnotherWorkspace(): void
    {
        $mine = $this->rows->workspace();
        $myCustomer = $this->rows->customer($mine);
        $theirs = $this->rows->workspace();
        $theirJob = $this->rows->job($theirs, $this->rows->customer($theirs));

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->insert('time_blocks', [
            'workspace_id' => $mine,
            'customer_id' => $myCustomer,
            'job_id' => $theirJob,
            'started_at' => '2026-01-05 09:00:00',
        ]));
    }

    public function testAnAfterPictureCannotFollowAPictureOfAnotherWorkspace(): void
    {
        $mine = $this->rows->workspace('personal');
        $theirPicture = $this->rows->picture($this->rows->workspace('personal'), null);

        $this->assertRejected(
            self::FOREIGN_KEY,
            fn() => $this->rows->picture($mine, null, ['after_of' => $theirPicture]),
        );
    }

    public function testAUserCannotBelongToACustomerOfAnotherWorkspace(): void
    {
        $mine = $this->rows->workspace();
        $theirCustomer = $this->rows->customer($this->rows->workspace());

        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->rows->user($mine, 'customer', $theirCustomer));
    }
}
