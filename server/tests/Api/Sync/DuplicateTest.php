<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Tests\Api\Operation;

/**
 * Plan 006 test P7 (D-179): an offline duplicate of a live unique value is
 * rejected as `duplicate` with the id of the live record, so the app can
 * re-point to it; a restore into a reused value too.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class DuplicateTest extends SyncTestCase
{
    public function testEveryLiveUniqueKeyAnswersDuplicateWithTheLiveId(): void
    {
        $ids = $this->graph();
        $cases = [
            'label name' => ['labels', ['name' => ' zerbrechlich   WIO-0001 '], $ids['labels']],
            'property key name' => ['property_keys', ['name' => 'GEWICHT WIO-0001'], $ids['property_keys']],
            'entry code' => ['entries', ['customer_id' => $ids['customers'], 'code' => 'WIO-0001'], $ids['entries']],
            'external ref' => ['customers', ['name' => 'Familie Doppelt', 'external_ref' => 'K-WIO-0001'], $ids['customers']],
            'label link' => ['entity_labels', ['entity_type' => 'entry', 'entity_id' => $ids['entries'], 'label_id' => $ids['labels']], $ids['entity_labels']],
            'property link' => ['entity_properties', ['entity_type' => 'entry', 'entity_id' => $ids['entries'], 'key_id' => $ids['property_keys'], 'value_text' => 'schwer'], $ids['entity_properties']],
        ];
        foreach ($cases as $case => [$entity, $fields, $live]) {
            $result = $this->pushOne(self::change($entity, self::id(), fields: $fields), $this->secondToken);
            self::assertRejected('duplicate', $result, $case);
            self::assertSame($live, $result['existing_id'] ?? null, $case);
        }
        self::assertSame(1, $this->countLive('labels'));
    }

    public function testAnEditIntoATakenValueIsADuplicateToo(): void
    {
        $keller = self::id();
        $garage = self::id();
        $this->write('labels', $keller, ['name' => 'Keller']);
        $this->write('labels', $garage, ['name' => 'Garage']);

        $result = $this->pushOne(self::change('labels', $garage, fields: ['name' => 'keller']));

        self::assertRejected('duplicate', $result);
        self::assertSame($keller, $result['existing_id'] ?? null);
    }

    public function testADeletedRecordFreesItsValueAndARestoreIntoItIsADuplicate(): void
    {
        $old = self::id();
        $new = self::id();
        $this->write('labels', $old, ['name' => 'Keller']);
        $this->write('labels', $old, op: 'delete');
        $this->write('labels', $new, ['name' => 'Keller']);

        $result = $this->pushOne(self::change('labels', $old, 'restore'));

        self::assertRejected('duplicate', $result);
        self::assertSame($new, $result['existing_id'] ?? null);
        self::assertNotNull($this->pulled('labels', $old)['deleted_at'] ?? null, 'the old label stays deleted');
    }

    public function testADuplicateIsRememberedLikeAnyAnswer(): void
    {
        $live = self::id();
        $this->write('labels', $live, ['name' => 'Keller']);
        $change = self::change('labels', self::id(), fields: ['name' => 'Keller']);

        $first = $this->pushOne($change);
        $again = $this->pushOne($change);

        unset($first['detail']);
        self::assertSame($first, $again);
        self::assertSame($live, $again['existing_id'] ?? null);
    }

    public function testAnIdTakenInTheWorkspaceIsNotADuplicate(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $otherToken = $this->fixtures->token($other, $this->fixtures->user($other, email: 'andere@example.org'))['token'];

        $result = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Keller']), $otherToken);

        self::assertRejected('invalid', $result);
        self::assertArrayNotHasKey('existing_id', $result, 'never an id of another workspace');
    }

    private function countLive(string $table): int
    {
        $value = $this->sql->run("SELECT COUNT(*) FROM {$table} WHERE deleted_at IS NULL")->fetchColumn();

        return is_numeric($value) ? (int) $value : -1;
    }
}
