<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

/**
 * The CHECK constraints of schema v1 (D-47, D-53 and the role rules of D-13).
 */
final class ChecksTest extends SchemaTestCase
{
    private string $workspace;
    private string $customer;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->rows->workspace();
        $this->customer = $this->rows->customer($this->workspace);
    }

    public function testIdsMustBeCanonicalLowerCaseUuids(): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('labels', [
            'id' => strtoupper(Rows::uuid()),
            'workspace_id' => $this->workspace,
            'name' => 'A',
            'name_key' => 'a',
        ]));
        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('labels', [
            'id' => 'not-a-uuid',
            'workspace_id' => $this->workspace,
            'name' => 'B',
            'name_key' => 'b',
        ]));
    }

    public function testAWorkspaceIsPersonalOrProfessional(): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->rows->workspace('premium'));
    }

    public function testRolesFollowTheirRules(): void
    {
        self::assertNotSame('', $this->rows->user($this->workspace, 'owner'));
        self::assertNotSame('', $this->rows->user($this->workspace, 'customer', $this->customer));
        self::assertNotSame('', $this->rows->user($this->workspace, 'helper', $this->customer));

        $this->assertRejected(self::CHECK, fn() => $this->rows->user($this->workspace, 'owner', $this->customer));
        $this->assertRejected(self::CHECK, fn() => $this->rows->user($this->workspace, 'customer'));
        $this->assertRejected(self::CHECK, fn() => $this->rows->user($this->workspace, 'admin'));
        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('users', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'role' => 'helper',
        ]));
    }

    public function testAnEmailNeedsItsKey(): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('users', [
            'workspace_id' => $this->workspace,
            'role' => 'owner',
            'email' => 'chef@example.org',
        ]));
    }

    public function testAnOpeningIsADoorOrAWindow(): void
    {
        $site = $this->rows->site($this->workspace, $this->customer);
        $room = $this->rows->room($this->workspace, $site, $this->customer);
        $opening = fn(string $kind): string => $this->rows->insert('openings', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'room_id' => $room,
            'kind' => $kind,
            'wall_index' => 0,
            'offset_cm' => 50,
            'width_cm' => 90,
        ]);

        self::assertNotSame('', $opening('door'));
        $this->assertRejected(self::CHECK, fn() => $opening('hatch'));
    }

    public function testAFixtureRotationStaysBelow360Degrees(): void
    {
        $site = $this->rows->site($this->workspace, $this->customer);
        $room = $this->rows->room($this->workspace, $site, $this->customer);

        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('fixtures', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'room_id' => $room,
            'rotation_deg' => 360,
        ]));
    }

    public function testJsonColumnsHoldValidJson(): void
    {
        $site = $this->rows->site($this->workspace, $this->customer);

        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('rooms', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'site_id' => $site,
            'outline' => '[[0,0],[400,0]',
        ]));
        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('customers', [
            'workspace_id' => $this->workspace,
            'contact' => 'phone: 0123',
        ]));
    }

    public function testLabelsAndPropertiesOnlyHangOnKnownSubjects(): void
    {
        $label = $this->rows->label($this->workspace, 'Keller');

        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('entity_labels', [
            'workspace_id' => $this->workspace,
            'entity_type' => 'job',
            'entity_id' => Rows::uuid(),
            'label_id' => $label,
        ]));
    }

    public function testAPropertyHasATextOrANumberValueNotBoth(): void
    {
        $key = $this->rows->insert('property_keys', ['workspace_id' => $this->workspace, 'name' => 'Ziel', 'name_key' => 'ziel']);

        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('entity_properties', [
            'workspace_id' => $this->workspace,
            'entity_type' => 'room',
            'entity_id' => Rows::uuid(),
            'key_id' => $key,
            'value_text' => 'drei',
            'value_number' => 3,
        ]));
    }

    public function testANoteHasTextOrAudioAndAKnownSubject(): void
    {
        $note = fn(array $values): string => $this->rows->insert('notes', $values + [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'subject_type' => 'customer',
            'subject_id' => $this->customer,
        ]);

        self::assertNotSame('', $note(['text' => 'Schlüssel beim Nachbarn']));
        self::assertNotSame('', $note(['audio_sha256' => str_repeat('cd', 32), 'audio_bytes' => 2048, 'audio_seconds' => 4]));
        $this->assertRejected(self::CHECK, fn() => $note([]));
        $this->assertRejected(self::CHECK, fn() => $note(['text' => 'x', 'subject_type' => 'workspace']));
        $this->assertRejected(self::CHECK, fn() => $note(['text' => 'x', 'transcript' => 'y']));
        $this->assertRejected(self::CHECK, fn() => $note(['text' => 'x', 'transcript' => 'y', 'transcript_source' => 'cloud']));
        $this->assertRejected(self::CHECK, fn() => $note(['audio_sha256' => 'ABC', 'audio_bytes' => 1]));
    }

    public function testAPictureHashIsLowerCaseSha256AndNotItsOwnAfterPicture(): void
    {
        $this->assertRejected(
            self::CHECK,
            fn() => $this->rows->picture($this->workspace, $this->customer, ['file_sha256' => str_repeat('AB', 32)]),
        );
        $id = Rows::uuid();
        $this->assertRejected(
            self::CHECK,
            fn() => $this->rows->picture($this->workspace, $this->customer, ['id' => $id, 'after_of' => $id]),
        );
    }

    public function testATimeBlockEndsAfterItStarts(): void
    {
        $job = $this->rows->job($this->workspace, $this->customer);

        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('time_blocks', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'job_id' => $job,
            'started_at' => '2026-01-05 10:00:00',
            'ended_at' => '2026-01-05 09:59:59',
        ]));
    }

    public function testASignatureIsJson(): void
    {
        $job = $this->rows->job($this->workspace, $this->customer);

        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('sign_offs', [
            'workspace_id' => $this->workspace,
            'customer_id' => $this->customer,
            'job_id' => $job,
            'minutes_confirmed' => 240,
            'signature' => 'strokes',
            'signed_at' => '2026-01-05 16:00:00',
        ]));
    }

    public function testAConflictNamesASyncedTable(): void
    {
        $this->assertRejected(self::CHECK, fn() => $this->rows->insert('conflicts', [
            'workspace_id' => $this->workspace,
            'entity' => 'schema_migrations',
            'entity_id' => Rows::uuid(),
            'field' => 'version',
            'won_revision' => 2,
        ]));
    }
}
