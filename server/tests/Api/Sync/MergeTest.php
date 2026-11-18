<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Tests\Api\Contract\RecordFields;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 test P3 (D-173): field by field, server order wins; the earlier
 * value of a same-field clash is kept in `conflicts` for the owner.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class MergeTest extends SyncTestCase
{
    public function testDifferentFieldsFromTwoDevicesAreBothKept(): void
    {
        $customer = self::id();
        $base = $this->write('customers', $customer, ['name' => 'Familie Beispiel', 'external_ref' => 'K-1']);

        $a = $this->pushOne(self::change('customers', $customer, fields: ['name' => 'Familie Muster'], base: $base));
        $b = $this->pushOne(self::change('customers', $customer, fields: ['external_ref' => 'K-2'], base: $base), $this->secondToken);

        self::assertSame('applied', $a['status']);
        self::assertSame('merged', $b['status'], 'someone changed the record meanwhile');
        $pulled = $this->pulled('customers', $customer);
        self::assertSame('Familie Muster', $pulled['name'] ?? null);
        self::assertSame('K-2', $pulled['external_ref'] ?? null);
        self::assertSame(0, $this->fixtures->count('conflicts'));
    }

    public function testTheSameFieldKeepsTheLaterValueAndRecordsTheEarlierOne(): void
    {
        $customer = self::id();
        $base = $this->write('customers', $customer, ['name' => 'Familie Beispiel', 'contact' => ['email' => 'alt@example.org']]);
        $first = self::change('customers', $customer, fields: ['contact' => ['email' => 'eins@example.org']], base: $base);
        $this->pushOne($first);

        $second = $this->pushOne(self::change('customers', $customer, fields: ['contact' => ['email' => 'zwei@example.org'], 'name' => 'Familie Beispiel'], base: $base), $this->secondToken);

        self::assertSame('merged', $second['status']);
        self::assertEquals(['email' => 'zwei@example.org'], $this->pulled('customers', $customer)['contact'] ?? null);
        $conflicts = array_values(array_filter($this->pullAll()[0], static fn(array $r): bool => $r['entity'] === 'conflicts'));
        self::assertCount(1, $conflicts, 'only contact clashed: name was written again with its stored value');
        $conflict = $conflicts[0]['fields'];
        RecordFields::checkPulled('conflicts', $conflict);
        self::assertSame('customers', $conflict['entity']);
        self::assertSame($customer, $conflict['entity_id']);
        self::assertSame('contact', $conflict['field']);
        self::assertEquals(['email' => 'eins@example.org'], $conflict['lost_value']);
        self::assertSame($first['change_id'], $conflict['lost_change_id']);
        self::assertSame($second['revision'], $conflict['won_revision']);
        self::assertGreaterThan($second['revision'], $conflicts[0]['revision'], 'the conflict row has a revision of its own');
    }

    public function testTwoDevicesWritingTheSameValueIsNoConflict(): void
    {
        $label = self::id();
        $base = $this->write('labels', $label, ['name' => 'Keller']);
        $this->write('labels', $label, ['name' => 'Garage'], base: $base);

        $result = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Garage'], base: $base), $this->secondToken);

        self::assertSame('merged', $result['status']);
        self::assertSame(0, $this->fixtures->count('conflicts'));
    }

    public function testNoConflictWhenTheDeviceHadSeenTheEarlierValue(): void
    {
        $label = self::id();
        $base = $this->write('labels', $label, ['name' => 'Keller']);
        $seen = $this->write('labels', $label, ['name' => 'Dachboden'], base: $base);

        $result = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Garage'], base: $seen), $this->secondToken);

        self::assertSame('applied', $result['status']);
        self::assertSame(0, $this->fixtures->count('conflicts'));
    }

    public function testANullBaseCountsAsZero(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);

        $result = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Garage']), $this->secondToken);

        self::assertSame('merged', $result['status']);
        self::assertSame(1, $this->fixtures->count('conflicts'));
    }

    public function testOneDeviceOverwritingItsOwnValueIsNoConflict(): void
    {
        $label = self::id();
        $base = $this->write('labels', $label, ['name' => 'Keller']);
        // Two edits from one offline phone, both made on top of the same pulled revision.
        $this->write('labels', $label, ['name' => 'Kellr'], base: $base, token: $this->secondToken);
        $result = $this->pushOne(self::change('labels', $label, fields: ['name' => 'Keller 2'], base: $base), $this->secondToken);

        self::assertSame('merged', $result['status']);
        self::assertSame(0, $this->fixtures->count('conflicts'));
        self::assertSame('Keller 2', $this->pulled('labels', $label)['name'] ?? null);
    }

    public function testAnOwnerDismissesAConflictByDeletingIt(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        $this->pushOne(self::change('labels', $label, fields: ['name' => 'Garage']), $this->secondToken);
        $conflict = $this->sql->row('SELECT id FROM conflicts');
        self::assertIsArray($conflict);
        $id = self::str($conflict['id']);

        self::assertRejected('permission', $this->pushOne(self::change('conflicts', $id, fields: ['field' => 'name'])));
        $this->write('conflicts', $id, op: 'delete');

        self::assertNotNull($this->pulled('conflicts', $id)['deleted_at'] ?? null);
    }
}
