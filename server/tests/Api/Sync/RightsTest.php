<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Sync\RecordSchemas;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 test P11 (D-181): every role × entity × op cell of the push
 * rights. The expectations are written out here on their own, not read from
 * Sync\Rights, so a change of either shows up in review.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class RightsTest extends SyncTestCase
{
    /** @var array<string, array<string, list<string>>> role => op => entities allowed */
    private const array ALLOWED = [
        'owner' => [
            'create' => ['customers', 'sites', 'rooms', 'openings', 'fixtures', 'entries', 'pictures', 'notes', 'labels', 'property_keys', 'entity_labels', 'entity_properties', 'jobs', 'time_blocks', 'sign_offs', 'expenses'],
            'edit' => ['workspaces', 'customers', 'sites', 'rooms', 'openings', 'fixtures', 'entries', 'pictures', 'notes', 'labels', 'property_keys', 'entity_labels', 'entity_properties', 'jobs', 'time_blocks', 'sign_offs', 'expenses'],
            'delete' => ['customers', 'sites', 'rooms', 'openings', 'fixtures', 'entries', 'pictures', 'notes', 'labels', 'property_keys', 'entity_labels', 'entity_properties', 'jobs', 'time_blocks', 'sign_offs', 'expenses', 'conflicts'],
            'restore' => ['customers', 'sites', 'rooms', 'openings', 'fixtures', 'entries', 'pictures', 'notes', 'labels', 'property_keys', 'entity_labels', 'entity_properties', 'jobs', 'time_blocks', 'sign_offs', 'expenses'],
            'move_entry' => ['entries'],
        ],
        // On records of their own customer that the owner made.
        'customer' => [
            'create' => ['pictures', 'notes', 'entity_labels'],
            'edit' => [],
            'delete' => ['entity_labels'],
            'restore' => ['entity_labels'],
            'move_entry' => [],
        ],
        'helper' => ['create' => [], 'edit' => [], 'delete' => [], 'restore' => [], 'move_entry' => []],
    ];

    /** @var array<string, string> */
    private array $ids;

    /** @var array<string, string> role => token */
    private array $tokens;

    private int $serial = 0;

    protected function setUp(): void
    {
        parent::setUp();
        $this->ids = $this->graph();
        $this->ids['workspaces'] = $this->workspace;
        $this->ids['users'] = $this->owner;
        $this->write('entries', $this->ids['entries'], ['site_id' => $this->ids['sites'], 'room_id' => $this->ids['rooms']], 'move_entry');
        $this->ids['place_history'] = self::str($this->sql->row('SELECT id FROM place_history')['id'] ?? null);
        $this->pushOne(self::change('labels', $this->ids['labels'], fields: ['name' => 'Zerbrechlich']), $this->secondToken);
        $this->ids['conflicts'] = self::str($this->sql->row('SELECT id FROM conflicts')['id'] ?? null);

        $customer = $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org', customerId: $this->ids['customers']);
        $helper = $this->fixtures->user($this->workspace, 'helper', 'helfer@example.org', customerId: $this->ids['customers']);
        $this->tokens = [
            'helper' => $this->fixtures->token($this->workspace, $helper)['token'],
            'customer' => $this->fixtures->token($this->workspace, $customer)['token'],
            'owner' => $this->ownerToken,
        ];
    }

    public function testEveryRoleEntityAndOpCell(): void
    {
        $cells = 0;
        // Helpers and customers first: refused changes leave the graph as it is.
        foreach ($this->tokens as $role => $token) {
            foreach (array_keys(RecordSchemas::FIELDS) as $entity) {
                foreach (['create', 'edit', 'delete', 'restore', 'move_entry'] as $op) {
                    if ($op === 'move_entry' && $entity !== 'entries') {
                        continue;
                    }
                    $change = match ($op) {
                        'create' => self::change($entity, self::id(), fields: $this->createFields($entity)),
                        'edit' => self::change($entity, $this->ids[$entity], fields: $this->editFields($entity)),
                        'move_entry' => self::change($entity, $this->ids[$entity], 'move_entry', ['site_id' => $this->ids['sites'], 'room_id' => $this->ids['rooms'], 'floor_x_cm' => $this->serial++, 'floor_y_cm' => 0]),
                        default => self::change($entity, $this->ids[$entity], $op),
                    };
                    $result = $this->pushOne($change, $token);
                    $cell = "{$role} {$op} {$entity}";
                    if (\in_array($entity, self::ALLOWED[$role][$op], true)) {
                        self::assertContains($result['status'], ['applied', 'merged'], $cell . ' ' . json_encode($result));
                    } else {
                        self::assertRejected('permission', $result, $cell);
                    }
                    ++$cells;
                }
            }
        }
        self::assertSame(3 * (20 * 4 + 1), $cells);
    }

    public function testACustomerChangesOnlyTheirOwnPicturesAndNotes(): void
    {
        $token = $this->tokens['customer'];
        foreach (['pictures', 'notes'] as $entity) {
            $own = self::id();
            $this->write($entity, $own, $this->createFields($entity), token: $token);
            $this->write($entity, $own, $this->editFields($entity), token: $token);
            $this->write($entity, $own, op: 'delete', token: $token);
            $this->write($entity, $own, op: 'restore', token: $token);

            foreach (['delete', 'restore'] as $op) {
                self::assertRejected('permission', $this->pushOne(self::change($entity, $this->ids[$entity], $op), $token), "{$op} the owner's {$entity}");
            }
        }
    }

    public function testAnOwnerEditOfACustomersNoteKeepsItTheCustomers(): void
    {
        $note = self::id();
        $this->write('notes', $note, $this->createFields('notes'), token: $this->tokens['customer']);
        $this->write('notes', $note, ['text' => 'Vom Inhaber ergänzt']);

        $pulled = $this->pulled('notes', $note);
        self::assertIsArray($pulled);
        self::assertNotSame($this->owner, $pulled['created_by']);
        self::assertSame($this->owner, $pulled['updated_by']);
        $this->write('notes', $note, ['text' => 'Vom Kunden korrigiert'], token: $this->tokens['customer']);
    }

    public function testACustomerNeverReachesAnotherCustomer(): void
    {
        $other = $this->graph('WIO-0002');
        $token = $this->tokens['customer'];
        $cases = [
            'picture on another customer\'s entry' => ['pictures', ['entry_id' => $other['entries'], 'file_sha256' => self::SHA, 'file_bytes' => 1, 'file_mime' => 'image/jpeg', 'width_px' => 1, 'height_px' => 1]],
            'picture without parent for another customer' => ['pictures', ['customer_id' => $other['customers'], 'file_sha256' => self::SHA, 'file_bytes' => 1, 'file_mime' => 'image/jpeg', 'width_px' => 1, 'height_px' => 1]],
            'picture without any customer' => ['pictures', ['file_sha256' => self::SHA, 'file_bytes' => 1, 'file_mime' => 'image/jpeg', 'width_px' => 1, 'height_px' => 1]],
            'note on another customer' => ['notes', ['subject_type' => 'customer', 'subject_id' => $other['customers'], 'text' => 'x']],
            'label on another customer\'s entry' => ['entity_labels', ['entity_type' => 'entry', 'entity_id' => $other['entries'], 'label_id' => $other['labels']]],
            'label on their own room' => ['entity_labels', ['entity_type' => 'room', 'entity_id' => $this->ids['rooms'], 'label_id' => $other['labels']]],
        ];
        foreach ($cases as $case => [$entity, $fields]) {
            self::assertRejected('permission', $this->pushOne(self::change($entity, self::id(), fields: $fields), $token), $case);
        }
        foreach (['delete', 'restore'] as $op) {
            self::assertRejected('permission', $this->pushOne(self::change('entity_labels', $other['entity_labels'], $op), $token), "{$op} another customer's label link");
        }
    }

    public function testAnOwnerEditsTheNameButNeverThePlanOfTheirWorkspace(): void
    {
        $this->write('workspaces', $this->workspace, ['name' => 'Umzüge Beispiel']);
        self::assertSame('Umzüge Beispiel', $this->pulled('workspaces', $this->workspace)['name'] ?? null);

        self::assertRejected('permission', $this->pushOne(self::change('workspaces', $this->workspace, fields: ['plan' => 'personal'])));
        self::assertRejected('permission', $this->pushOne(self::change('workspaces', $this->workspace, fields: ['name' => 'X', 'plan' => 'professional'])));
        self::assertSame('professional', $this->pulled('workspaces', $this->workspace)['plan'] ?? null);
    }

    /**
     * @return array<string, mixed>
     */
    private function createFields(string $entity): array
    {
        $n = ++$this->serial;
        $label = self::id();
        if ($entity === 'entity_labels') {
            $this->write('labels', $label, ['name' => "Label {$n}"]);
        }
        $ids = $this->ids;

        return match ($entity) {
            'workspaces' => ['name' => 'Neu', 'plan' => 'personal'],
            'users' => ['role' => 'helper', 'display_name' => 'Helfer', 'expires_at' => '2027-01-01T00:00:00.000Z', 'customer_id' => $ids['customers']],
            'customers' => ['name' => "Familie {$n}"],
            'sites' => ['customer_id' => $ids['customers'], 'name' => 'Neubau'],
            'rooms' => ['site_id' => $ids['sites'], 'name' => 'Bad'],
            'openings' => ['room_id' => $ids['rooms'], 'kind' => 'window', 'wall_index' => 1, 'offset_cm' => 0, 'width_cm' => 100],
            'fixtures' => ['room_id' => $ids['rooms'], 'name' => 'Schrank'],
            'entries' => ['customer_id' => $ids['customers'], 'title' => 'Lampe'],
            'place_history' => ['entry_id' => $ids['entries'], 'moved_at' => '2026-11-18T10:00:00.000Z'],
            'pictures' => ['entry_id' => $ids['entries'], 'file_sha256' => self::SHA, 'file_bytes' => 1, 'file_mime' => 'image/jpeg', 'width_px' => 1, 'height_px' => 1],
            'notes' => ['subject_type' => 'entry', 'subject_id' => $ids['entries'], 'text' => 'Notiz'],
            'labels' => ['name' => "Neu {$n}"],
            'property_keys' => ['name' => "Schlüssel {$n}"],
            'entity_labels' => ['entity_type' => 'entry', 'entity_id' => $ids['entries'], 'label_id' => $label],
            'entity_properties' => ['entity_type' => 'entry', 'entity_id' => $ids['entries'], 'key_id' => $this->propertyKey($n), 'value_text' => 'x'],
            'jobs' => ['customer_id' => $ids['customers'], 'date' => '2026-11-21'],
            'time_blocks' => ['job_id' => $ids['jobs'], 'started_at' => '2026-11-21T08:00:00.000Z'],
            'sign_offs' => ['job_id' => $ids['jobs'], 'minutes_confirmed' => 1, 'signature' => [], 'signed_at' => '2026-11-21T16:00:00.000Z'],
            'expenses' => ['job_id' => $ids['jobs'], 'amount_cents' => 1],
            'conflicts' => ['entity' => 'labels', 'entity_id' => $ids['labels'], 'field' => 'name', 'won_revision' => 1],
            default => self::fail("No fields for {$entity}"),
        };
    }

    /**
     * @return array<string, mixed>
     */
    private function editFields(string $entity): array
    {
        $n = ++$this->serial;

        return match ($entity) {
            'workspaces', 'customers', 'sites', 'rooms', 'fixtures' => ['name' => "Name {$n}"],
            'users' => ['display_name' => 'Neuer Name'],
            'openings' => ['offset_cm' => $n],
            'entries' => ['title' => "Titel {$n}"],
            'place_history' => ['moved_at' => '2026-11-18T10:00:00.000Z'],
            'pictures' => ['width_px' => $n],
            'notes' => ['text' => "Text {$n}"],
            'labels', 'property_keys' => ['name' => "Name {$n}"],
            'entity_labels' => ['label_id' => $this->ids['labels']],
            'entity_properties' => ['value_number' => (string) $n],
            'jobs' => ['agreed_minutes' => $n],
            'time_blocks' => ['ended_at' => '2026-11-20T12:00:00.000Z'],
            'sign_offs' => ['minutes_confirmed' => $n],
            'expenses' => ['amount_cents' => $n],
            'conflicts' => ['field' => 'name'],
            default => self::fail("No fields for {$entity}"),
        };
    }

    private function propertyKey(int $n): string
    {
        $key = self::id();
        $this->write('property_keys', $key, ['name' => "Eigenschaft {$n}"]);

        return $key;
    }
}
