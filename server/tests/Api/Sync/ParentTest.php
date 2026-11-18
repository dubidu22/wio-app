<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Tests\Api\Operation;

/**
 * Plan 006 tests P8 (subject check, D-180) and P9 (customer_id derived from
 * the parent, D-178).
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class ParentTest extends SyncTestCase
{
    public function testLinksAndNotesNeedALiveSubjectOfTheSameWorkspaceAndCustomer(): void
    {
        $ids = $this->graph();
        $other = $this->graph('WIO-0002');
        $foreign = $this->foreignEntry();
        $deleted = self::id();
        $this->write('entries', $deleted, ['customer_id' => $ids['customers'], 'code' => 'WIO-0003']);
        $this->write('entries', $deleted, op: 'delete');

        $subjects = [
            'missing' => self::id(),
            'other workspace' => $foreign,
            'deleted' => $deleted,
        ];
        foreach ($subjects as $case => $entry) {
            self::assertRejected('invalid', $this->pushOne(self::change('entity_labels', self::id(), fields: ['entity_type' => 'entry', 'entity_id' => $entry, 'label_id' => $ids['labels']])), "label link, {$case}");
            self::assertRejected('invalid', $this->pushOne(self::change('entity_properties', self::id(), fields: ['entity_type' => 'entry', 'entity_id' => $entry, 'key_id' => $ids['property_keys'], 'value_text' => 'x'])), "property link, {$case}");
            self::assertRejected('invalid', $this->pushOne(self::change('notes', self::id(), fields: ['subject_type' => 'entry', 'subject_id' => $entry, 'text' => 'x'])), "note, {$case}");
        }
        // A subject of another customer: its customer_id is not the pushed one.
        foreach ([
            ['entity_labels', ['entity_type' => 'entry', 'entity_id' => $other['entries'], 'label_id' => $ids['labels'], 'customer_id' => $ids['customers']]],
            ['entity_properties', ['entity_type' => 'entry', 'entity_id' => $other['entries'], 'key_id' => $ids['property_keys'], 'value_text' => 'x', 'customer_id' => $ids['customers']]],
            ['notes', ['subject_type' => 'entry', 'subject_id' => $other['entries'], 'text' => 'x', 'customer_id' => $ids['customers']]],
        ] as [$entity, $fields]) {
            self::assertRejected('invalid', $this->pushOne(self::change($entity, self::id(), fields: $fields)), "{$entity}, other customer");
        }
        // A subject of the wrong type: a room id named as an entry.
        self::assertRejected('invalid', $this->pushOne(self::change('notes', self::id(), fields: ['subject_type' => 'entry', 'subject_id' => $ids['rooms'], 'text' => 'x'])));
        // A note on a customer: the customer is its own subject.
        $note = self::id();
        $this->write('notes', $note, ['subject_type' => 'customer', 'subject_id' => $ids['customers'], 'text' => 'Klingel defekt']);
        self::assertSame($ids['customers'], $this->pulled('notes', $note)['customer_id'] ?? null);
    }

    public function testAnExistingLinkCanBeEditedAfterItsSubjectWasDeleted(): void
    {
        $ids = $this->graph();
        $this->write('entries', $ids['entries'], op: 'delete');

        $this->write('entity_properties', $ids['entity_properties'], ['value_number' => '13']);

        self::assertSame('13', $this->pulled('entity_properties', $ids['entity_properties'])['value_number'] ?? null);
    }

    public function testCustomerIdIsFilledFromTheParentAndAMismatchIsInvalid(): void
    {
        $ids = $this->graph();
        $other = $this->graph('WIO-0002');
        $children = [
            'rooms' => ['site_id' => $ids['sites'], 'name' => 'Bad'],
            'openings' => ['room_id' => $ids['rooms'], 'kind' => 'window', 'wall_index' => 1, 'offset_cm' => 0, 'width_cm' => 100],
            'fixtures' => ['room_id' => $ids['rooms'], 'name' => 'Schrank'],
            'pictures' => ['room_id' => $ids['rooms'], 'file_sha256' => self::SHA, 'file_bytes' => 1, 'file_mime' => 'image/jpeg', 'width_px' => 1, 'height_px' => 1],
            'notes' => ['subject_type' => 'room', 'subject_id' => $ids['rooms'], 'text' => 'Fenster klemmt'],
            'entity_labels' => ['entity_type' => 'room', 'entity_id' => $ids['rooms'], 'label_id' => $ids['labels']],
            'entity_properties' => ['entity_type' => 'room', 'entity_id' => $ids['rooms'], 'key_id' => $ids['property_keys'], 'value_text' => 'feucht'],
            'time_blocks' => ['job_id' => $ids['jobs'], 'started_at' => '2026-11-20T13:00:00.000Z'],
            'sign_offs' => ['job_id' => $ids['jobs'], 'minutes_confirmed' => 10, 'signature' => [], 'signed_at' => '2026-11-20T16:00:00.000Z'],
            'expenses' => ['job_id' => $ids['jobs'], 'amount_cents' => 100],
        ];
        foreach ($children as $entity => $fields) {
            self::assertRejected('invalid', $this->pushOne(self::change($entity, self::id(), fields: $fields + ['customer_id' => $other['customers']])), "{$entity} with another customer");
            $id = self::id();
            $this->write($entity, $id, $fields);
            self::assertSame($ids['customers'], $this->pulled($entity, $id)['customer_id'] ?? null, "{$entity}.customer_id filled in");
            if (!str_starts_with($entity, 'entity_')) {
                $this->write($entity, self::id(), $fields + ['customer_id' => $ids['customers']]);
            }
        }
    }

    public function testAPlacedEntryTakesItsCustomerFromItsSite(): void
    {
        $ids = $this->graph();
        $other = $this->graph('WIO-0002');
        $this->write('entries', $ids['entries'], ['site_id' => $ids['sites'], 'room_id' => $ids['rooms']], 'move_entry');

        self::assertRejected('invalid', $this->pushOne(self::change('entries', $ids['entries'], fields: ['customer_id' => $other['customers']])));
        $this->write('entries', $ids['entries'], ['customer_id' => $ids['customers'], 'title' => 'Karton Bücher 2']);
        self::assertSame($ids['customers'], $this->pulled('entries', $ids['entries'])['customer_id'] ?? null);
    }

    public function testAChildWithoutItsParentIsInvalid(): void
    {
        self::assertRejected('invalid', $this->pushOne(self::change('rooms', self::id(), fields: ['name' => 'Bad'])));
        self::assertRejected('invalid', $this->pushOne(self::change('rooms', self::id(), fields: ['site_id' => self::id(), 'name' => 'Bad'])));
        self::assertRejected('invalid', $this->pushOne(self::change('time_blocks', self::id(), fields: ['started_at' => '2026-11-20T13:00:00.000Z'])));
    }

    public function testMovingARoomToASiteOfAnotherCustomerIsInvalidWhileItHasChildren(): void
    {
        $ids = $this->graph();
        $other = $this->graph('WIO-0002');

        self::assertRejected('invalid', $this->pushOne(self::change('rooms', $ids['rooms'], fields: ['site_id' => $other['sites']])));
        self::assertSame($ids['customers'], $this->pulled('rooms', $ids['rooms'])['customer_id'] ?? null);
    }

    public function testTopLevelRecordsTakeCustomerIdFromFields(): void
    {
        $ids = $this->graph();
        $site = self::id();
        $this->write('sites', $site, ['customer_id' => $ids['customers'], 'name' => 'Neubau']);
        self::assertSame($ids['customers'], $this->pulled('sites', $site)['customer_id'] ?? null);

        $entry = self::id();
        $this->write('entries', $entry, ['customer_id' => $ids['customers'], 'title' => 'Lampe']);
        self::assertSame($ids['customers'], $this->pulled('entries', $entry)['customer_id'] ?? null);

        self::assertRejected('invalid', $this->pushOne(self::change('sites', self::id(), fields: ['customer_id' => self::id(), 'name' => 'Nirgends'])), 'an unknown customer');
        self::assertRejected('invalid', $this->pushOne(self::change('jobs', self::id(), fields: ['date' => '2026-11-20'])), 'a job needs its customer');
    }

    private function foreignEntry(): string
    {
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $token = $this->fixtures->token($other, $this->fixtures->user($other, email: 'andere@example.org'))['token'];
        $entry = self::id();
        $this->write('entries', $entry, ['title' => 'Fremd'], token: $token);

        return $entry;
    }
}
