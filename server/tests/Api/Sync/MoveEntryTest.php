<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Tests\Api\Contract\RecordFields;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 test P10 (D-176, D-54): only move_entry changes a place, and it
 * writes the place and one place_history row in the same transaction.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class MoveEntryTest extends SyncTestCase
{
    public function testAMoveWritesThePlaceAndOneHistoryRow(): void
    {
        $ids = $this->graph();
        $this->clock->advance('PT5M');

        $revision = $this->write('entries', $ids['entries'], ['site_id' => $ids['sites'], 'room_id' => $ids['rooms'], 'fixture_id' => $ids['fixtures'], 'level' => 1, 'compartment' => 2], 'move_entry');

        $entry = $this->pulled('entries', $ids['entries']);
        self::assertIsArray($entry);
        self::assertSame($revision, $entry['revision']);
        self::assertSame([$ids['sites'], $ids['rooms'], $ids['fixtures'], 1, 2, null, null], [$entry['site_id'], $entry['room_id'], $entry['fixture_id'], $entry['level'], $entry['compartment'], $entry['floor_x_cm'], $entry['floor_y_cm']]);
        $history = $this->history($ids['entries']);
        self::assertCount(1, $history);
        RecordFields::checkPulled('place_history', $history[0]);
        self::assertNull($history[0]['from_site_id']);
        self::assertSame($ids['fixtures'], $history[0]['to_fixture_id']);
        self::assertSame(2, $history[0]['to_compartment']);
        self::assertSame($this->owner, $history[0]['moved_by']);
        self::assertSame('2026-11-18T10:05:00.000Z', $history[0]['moved_at']);
        self::assertSame($ids['customers'], $history[0]['customer_id']);
        self::assertGreaterThan($revision, $history[0]['revision']);

        // To the floor of the same room: the left-out fixture slot becomes null.
        $this->write('entries', $ids['entries'], ['site_id' => $ids['sites'], 'room_id' => $ids['rooms'], 'floor_x_cm' => 120, 'floor_y_cm' => 80], 'move_entry');
        $history = $this->history($ids['entries']);
        self::assertCount(2, $history);
        self::assertSame($ids['fixtures'], $history[1]['from_fixture_id']);
        self::assertNull($history[1]['to_fixture_id']);
        self::assertSame(120, $history[1]['to_floor_x_cm']);
    }

    public function testAMoveToTheSamePlaceWritesNothing(): void
    {
        $ids = $this->graph();
        $place = ['site_id' => $ids['sites'], 'room_id' => $ids['rooms']];
        $revision = $this->write('entries', $ids['entries'], $place, 'move_entry');

        self::assertSame($revision, $this->write('entries', $ids['entries'], $place, 'move_entry'));
        self::assertCount(1, $this->history($ids['entries']));
    }

    public function testPlaceFieldsInAnUpsertAreInvalid(): void
    {
        $ids = $this->graph();
        foreach (['site_id' => $ids['sites'], 'room_id' => $ids['rooms'], 'fixture_id' => $ids['fixtures'], 'level' => 1, 'compartment' => 1, 'floor_x_cm' => 1, 'floor_y_cm' => 1] as $field => $value) {
            self::assertRejected('invalid', $this->pushOne(self::change('entries', $ids['entries'], fields: [$field => $value])), $field);
            self::assertRejected('invalid', $this->pushOne(self::change('entries', self::id(), fields: ['customer_id' => $ids['customers'], $field => $value])), "new entry with {$field}");
        }
        $wholePlace = ['site_id' => $ids['sites'], 'room_id' => $ids['rooms']];
        self::assertRejected('invalid', $this->pushOne(self::change('entries', $ids['entries'], fields: $wholePlace)), 'a whole valid place');
        $this->write('entries', $ids['entries'], ['target_site_id' => $ids['sites'], 'target_room_id' => $ids['rooms']]);
        self::assertSame([], $this->history($ids['entries']), 'the target place is not the place');
    }

    public function testAMoveCarriesOnlyPlaceFieldsAndAValidPlace(): void
    {
        $ids = $this->graph();
        $other = $this->graph('WIO-0002');
        $bad = [
            'a title' => ['site_id' => $ids['sites'], 'room_id' => $ids['rooms'], 'title' => 'x'],
            'a room of another site' => ['site_id' => $other['sites'], 'room_id' => $ids['rooms']],
            'a site without room' => ['site_id' => $ids['sites']],
            'a slot without fixture' => ['site_id' => $ids['sites'], 'room_id' => $ids['rooms'], 'level' => 1],
            'a site of another customer' => ['site_id' => $other['sites'], 'room_id' => $other['rooms']],
            'an unknown site' => ['site_id' => self::id(), 'room_id' => $ids['rooms']],
        ];
        foreach ($bad as $case => $place) {
            self::assertRejected('invalid', $this->pushOne(self::change('entries', $ids['entries'], 'move_entry', $place)), $case);
        }
        self::assertSame([], $this->history($ids['entries']), 'nothing written by a refused move');
        $entry = $this->pulled('entries', $ids['entries']);
        self::assertIsArray($entry);
        self::assertNull($entry['site_id'], 'the entry did not move');
    }

    public function testAMoveOfADeletedEntryIsRejected(): void
    {
        $ids = $this->graph();
        $this->write('entries', $ids['entries'], op: 'delete');

        self::assertRejected('deleted', $this->pushOne(self::change('entries', $ids['entries'], 'move_entry', ['site_id' => $ids['sites'], 'room_id' => $ids['rooms']])));
    }

    public function testPlaceHistoryCannotBePushed(): void
    {
        foreach (['upsert', 'delete', 'restore'] as $op) {
            self::assertRejected('permission', $this->pushOne(self::change('place_history', self::id(), $op)), $op);
        }
    }

    public function testTwoDevicesMovingOneEntryKeepTheLaterPlace(): void
    {
        $ids = $this->graph();
        $room = self::id();
        $this->write('rooms', $room, ['site_id' => $ids['sites'], 'name' => 'Flur']);
        $entry = $this->pulled('entries', $ids['entries']);
        self::assertIsArray($entry);
        self::assertIsInt($entry['revision']);

        $this->write('entries', $ids['entries'], ['site_id' => $ids['sites'], 'room_id' => $ids['rooms']], 'move_entry', $entry['revision']);
        $later = $this->pushOne(self::change('entries', $ids['entries'], 'move_entry', ['site_id' => $ids['sites'], 'room_id' => $room], $entry['revision']), $this->secondToken);

        self::assertSame('merged', $later['status']);
        self::assertSame($room, $this->pulled('entries', $ids['entries'])['room_id'] ?? null);
        self::assertCount(2, $this->history($ids['entries']));
        $lost = $this->sql->row("SELECT lost_value FROM conflicts WHERE field = 'room_id'");
        self::assertSame(json_encode($ids['rooms']), $lost['lost_value'] ?? null);
    }

    /**
     * @return list<array<string, mixed>>
     */
    private function history(string $entry): array
    {
        $rows = [];
        foreach ($this->pullAll()[0] as $record) {
            if ($record['entity'] === 'place_history' && $record['fields']['entry_id'] === $entry) {
                $rows[] = $record['fields'];
            }
        }

        return $rows;
    }
}
