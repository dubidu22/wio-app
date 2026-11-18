<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Tests\Api\Contract\RecordFields;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 tests P1 and P4: every pushable entity round-trips create, edit,
 * delete and restore through push and pull, with server fields set by the
 * server; and device clocks never change order or outcome.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class RoundTripTest extends SyncTestCase
{
    /** One field to edit per entity, with its new value. */
    private const array EDITS = [
        'customers' => ['name', 'Familie Muster'],
        'sites' => ['address', 'Beispielallee 2, 00000 Beispielstadt'],
        'rooms' => ['height_cm', 260],
        'openings' => ['kind', 'window'],
        'fixtures' => ['rotation_deg', 90],
        'entries' => ['title', 'Karton Geschirr'],
        'pictures' => ['taken_at', '2026-11-18T10:15:00.000Z'],
        'notes' => ['text', 'Sehr schwer'],
        'labels' => ['name', 'Glas'],
        'property_keys' => ['unit', 'g'],
        'entity_properties' => ['value_number', '-3.25'],
        'jobs' => ['agreed_minutes', 300],
        'time_blocks' => ['ended_at', '2026-11-20T12:00:00.000Z'],
        'sign_offs' => ['minutes_confirmed', 230],
        'expenses' => ['amount_cents', 1300],
    ];

    public function testEveryEntityRoundTripsThroughPushAndPull(): void
    {
        $ids = $this->graph();

        foreach ($ids as $entity => $id) {
            $created = $this->pulled($entity, $id);
            self::assertNotNull($created, "{$entity} is pulled");
            RecordFields::checkPulled($entity, $created);
            self::assertSame($id, $created['id']);
            self::assertSame($this->workspace, $created['workspace_id'], "{$entity}.workspace_id is the token's");
            self::assertSame('2026-11-18T10:00:00.000Z', $created['created_at'], "{$entity}.created_at is server time");
            self::assertSame($this->owner, $created['created_by']);
            self::assertNull($created['deleted_at']);
            foreach (['name_key', 'email_key', 'alive', 'no_customer'] as $server) {
                self::assertArrayNotHasKey($server, $created, "{$entity}.{$server} never leaves the server");
            }
            if (\array_key_exists('customer_id', $created)) {
                self::assertSame($ids['customers'], $created['customer_id'], "{$entity}.customer_id");
            }
        }

        $this->clock->advance('PT1H');
        foreach (self::EDITS as $entity => [$field, $value]) {
            $before = $this->pulled($entity, $ids[$entity]);
            self::assertIsArray($before);
            self::assertIsInt($before['revision']);
            $revision = $this->write($entity, $ids[$entity], [$field => $value], base: $before['revision']);
            $after = $this->pulled($entity, $ids[$entity]);
            self::assertIsArray($after);
            RecordFields::checkPulled($entity, $after);
            self::assertSame($value, $after[$field], "{$entity}.{$field} changed");
            self::assertSame($revision, $after['revision']);
            self::assertSame('2026-11-18T11:00:00.000Z', $after['updated_at']);
            self::assertSame($before['created_at'], $after['created_at']);
        }

        // Children first, so no restore depends on a deleted parent.
        foreach (array_reverse(array_keys($ids)) as $entity) {
            $this->write($entity, $ids[$entity], op: 'delete');
            $deleted = $this->pulled($entity, $ids[$entity]);
            self::assertIsArray($deleted);
            self::assertSame('2026-11-18T11:00:00.000Z', $deleted['deleted_at'], "{$entity} is a tombstone");
            RecordFields::checkPulled($entity, $deleted);
        }
        foreach (array_keys($ids) as $entity) {
            $this->write($entity, $ids[$entity], op: 'restore');
            $restored = $this->pulled($entity, $ids[$entity]);
            self::assertIsArray($restored);
            self::assertNull($restored['deleted_at'], "{$entity} is restored");
        }
    }

    public function testAnEditOfADeletedRecordIsRejectedAsDeleted(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        $this->write('labels', $label, op: 'delete');

        self::assertRejected('deleted', $this->pushOne(self::change('labels', $label, fields: ['name' => 'Dachboden'])));
    }

    public function testDeletingATombstoneAgainAnswersItsRevision(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        $deleted = $this->write('labels', $label, op: 'delete');

        $again = $this->pushOne(self::change('labels', $label, 'delete'));

        self::assertSame(['change_id' => $again['change_id'], 'status' => 'applied', 'revision' => $deleted], $again);
        [, $top] = $this->pullAll();
        self::assertSame($deleted, $top, 'no new revision was taken');
    }

    public function testServerFieldsCannotBePushed(): void
    {
        foreach (['id', 'workspace_id', 'created_at', 'created_by', 'updated_at', 'updated_by', 'revision', 'deleted_at', 'name_key', 'alive'] as $field) {
            $result = $this->pushOne(self::change('labels', self::id(), fields: ['name' => 'Keller', $field => null]));
            self::assertRejected('invalid', $result, $field);
        }
    }

    public function testFieldsAreCheckedAgainstTheRecordSchema(): void
    {
        $customer = self::id();
        $this->write('customers', $customer, ['name' => 'Familie Beispiel']);
        $bad = [
            ['labels', ['name' => str_repeat('x', 101)]],
            ['labels', ['name' => null]],
            ['labels', ['name' => 12]],
            ['labels', ['color' => 'rot']],
            ['labels', []],
            ['sites', ['customer_id' => 'not-a-uuid']],
            ['jobs', ['customer_id' => $customer, 'date' => '2026-02-30']],
            ['jobs', ['customer_id' => $customer, 'date' => '2026-11-20', 'agreed_minutes' => -1]],
            ['jobs', ['customer_id' => $customer, 'date' => '2026-11-20', 'report_sent_at' => '2026-11-20 10:00']],
            ['entity_properties', ['value_number' => '1e5']],
            ['openings', ['kind' => 'gate']],
            ['fixtures', ['levels' => [['height_cm' => 40]]]],
            ['fixtures', ['rotation_deg' => 360]],
            ['customers', ['contact' => ['a', 'b']]],
            ['customers', ['name' => 'Familie', 'contact' => 'Telefon']],
        ];
        foreach ($bad as [$entity, $fields]) {
            self::assertRejected('invalid', $this->pushOne(self::change($entity, self::id(), fields: $fields)), $entity . ' ' . json_encode($fields));
        }
    }

    public function testUnknownEntitiesAndOpsAreInvalid(): void
    {
        self::assertRejected('invalid', $this->pushOne(self::change('gadgets', self::id(), fields: ['name' => 'x'])));
        self::assertRejected('invalid', $this->pushOutsideSchema(self::change('labels', self::id(), 'rename', ['name' => 'x'])));
        self::assertRejected('invalid', $this->pushOne(self::change('labels', self::id(), 'move_entry')));
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        self::assertRejected('invalid', $this->pushOne(self::change('labels', $label, 'delete', ['name' => 'x'])), 'delete carries no fields');
    }

    public function testDeleteRestoreAndMoveOfAnUnknownIdAreNotFound(): void
    {
        foreach (['delete', 'restore'] as $op) {
            self::assertRejected('not_found', $this->pushOne(self::change('labels', self::id(), $op)), $op);
        }
        self::assertRejected('not_found', $this->pushOne(self::change('entries', self::id(), 'move_entry')));
    }

    public function testAnIdOfAnotherWorkspaceCannotBeUsedOrSeen(): void
    {
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $otherToken = $this->fixtures->token($other, $this->fixtures->user($other, email: 'andere@example.org'))['token'];
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller'], token: $otherToken);

        self::assertRejected('invalid', $this->pushOne(self::change('labels', $label, fields: ['name' => 'Dachboden'])));
        self::assertRejected('not_found', $this->pushOne(self::change('labels', $label, 'delete')));
        self::assertNull($this->pulled('labels', $label));
        self::assertSame('Keller', $this->pulled('labels', $label, $otherToken)['name'] ?? null);
    }

    public function testDeviceClocksNeverDecideOrderOrOutcome(): void
    {
        $label = self::id();
        $base = $this->write('labels', $label, ['name' => 'Keller']);
        // The later device clock arrives first; the earlier one arrives second and wins.
        $future = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Zukunft'], base: $base, deviceTime: '2031-01-01T00:00:00.000+05:00'));
        $past = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Vergangenheit'], base: $base, deviceTime: '2019-03-01T00:00:00.000Z'), $this->secondToken);

        self::assertSame('applied', $future['status']);
        self::assertSame('merged', $past['status']);
        self::assertGreaterThan($future['revision'], $past['revision']);
        self::assertSame('Vergangenheit', $this->pulled('labels', $label)['name'] ?? null);
        $conflict = $this->sql->row('SELECT lost_value FROM conflicts WHERE entity_id = ?', [$label]);
        self::assertSame('"Zukunft"', $conflict['lost_value'] ?? null, 'the server order decided, not the device clock');
    }
}
