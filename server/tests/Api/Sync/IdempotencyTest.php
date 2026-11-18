<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Tests\Api\Operation;

/**
 * Plan 006 tests P2 and P16 (D-172): the same change twice is applied once
 * and answered the same; a reused change_id with another payload is invalid;
 * a recorded rejection is replayed by design; old answers are purged.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class IdempotencyTest extends SyncTestCase
{
    public function testTheSameChangeTwiceIsAppliedOnceAndAnsweredTheSame(): void
    {
        $change = self::change('labels', self::id(), fields: ['name' => 'Keller']);

        $first = $this->pushOne($change);
        [, $top] = $this->pullAll();
        $second = $this->pushOne($change);
        $inOnePush = $this->push([$change, $change]);

        self::assertSame('applied', $first['status']);
        self::assertSame($first, $second);
        self::assertSame([$first, $first], $inOnePush);
        self::assertSame($top, $this->pullAll()[1], 'no new revision');
        self::assertSame(1, $this->fixtures->count('applied_changes'));
    }

    public function testAMergedAnswerIsReplayedToo(): void
    {
        $label = self::id();
        $base = $this->write('labels', $label, ['name' => 'Keller']);
        $this->write('labels', $label, ['name' => 'Dachboden'], base: $base);
        $late = self::change('labels', $label, fields: ['name' => 'Garage'], base: $base);

        $first = $this->pushOne($late, $this->secondToken);
        $again = $this->pushOne($late, $this->secondToken);

        self::assertSame('merged', $first['status']);
        self::assertSame($first, $again);
        self::assertSame(1, $this->fixtures->count('conflicts'), 'the conflict is not recorded twice');
    }

    public function testAReusedChangeIdWithAnotherPayloadIsInvalidAndChangesNothing(): void
    {
        $change = self::change('labels', self::id(), fields: ['name' => 'Keller']);
        $applied = $this->pushOne($change);

        foreach ([['name' => 'Dachboden'], ['name' => 'Keller', 'extra' => 1]] as $fields) {
            $reused = $change;
            $reused['fields'] = (object) $fields;
            self::assertRejected('invalid', $this->pushOne($reused));
        }
        $otherId = $change;
        $otherId['id'] = self::id();
        self::assertRejected('invalid', $this->pushOne($otherId));

        self::assertSame($applied, $this->pushOne($change), 'the original answer stays');
        self::assertSame('Keller', $this->pulled('labels', self::str($change['id']))['name'] ?? null);
    }

    public function testTheSamePayloadWithOtherKeyOrderIsTheSameChange(): void
    {
        $id = self::id();
        $change = self::change('customers', $id, fields: ['name' => 'Familie Beispiel', 'contact' => ['phone' => '000', 'email' => 'a@example.org']]);
        $first = $this->pushOne($change);
        $change['fields'] = (object) ['contact' => ['email' => 'a@example.org', 'phone' => '000'], 'name' => 'Familie Beispiel'];

        self::assertSame($first, $this->pushOne($change));
    }

    /**
     * PR A body and #44: a rejection is remembered like any answer. The app
     * fixes the cause and re-creates the change with a new change_id.
     */
    public function testARecordedRejectionIsReplayedEvenAfterItsCauseIsGone(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        $this->write('labels', $label, op: 'delete');
        $edit = self::change('labels', $label, fields: ['name' => 'Dachboden']);
        $rejected = $this->pushOne($edit);
        self::assertRejected('deleted', $rejected);

        $this->write('labels', $label, op: 'restore');

        $replayed = $this->pushOne($edit);
        unset($rejected['detail']);
        self::assertSame($rejected, $replayed, 'the same change_id gets the same answer');
        self::assertSame('Keller', $this->pulled('labels', $label)['name'] ?? null);

        $recreated = $edit;
        $recreated['change_id'] = self::id();
        self::assertSame('merged', $this->pushOne($recreated)['status'], 'applied; the record changed after its base (null)');
        self::assertSame('Dachboden', $this->pulled('labels', $label)['name'] ?? null);
    }

    public function testChangeIdsAreKeptPerWorkspace(): void
    {
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $otherToken = $this->fixtures->token($other, $this->fixtures->user($other, email: 'andere@example.org'))['token'];
        $change = self::change('labels', self::id(), fields: ['name' => 'Keller']);
        $this->pushOne($change);
        $theirs = $change;
        $theirs['id'] = self::id();

        self::assertSame('applied', $this->pushOne($theirs, $otherToken)['status'], 'another workspace never sees this change_id');
    }

    public function testAnswersOlderThan180DaysArePurgedAtMost1000PerPush(): void
    {
        $insert = function (string $createdAt, int $count): void {
            for ($i = 0; $i < $count; ++$i) {
                $this->sql->run(
                    "INSERT INTO applied_changes (workspace_id, change_id, payload_sha256, status, revision, created_at) VALUES (?, ?, ?, 'applied', 1, ?)",
                    [$this->workspace, self::id(), str_repeat('0', 64), $createdAt],
                );
            }
        };
        // The clock stands at 2026-11-18 10:00; 180 days before is 2026-05-22 10:00.
        $insert('2026-05-22 09:59:59.999', 1005);
        $insert('2026-05-22 10:00:00.000', 3);

        $this->write('labels', self::id(), ['name' => 'Keller']);
        self::assertSame(5 + 3 + 1, $this->fixtures->count('applied_changes'));

        $this->write('labels', self::id(), ['name' => 'Dachboden']);
        self::assertSame(3 + 2, $this->fixtures->count('applied_changes'), 'rows of exactly 180 days stay');
    }
}
