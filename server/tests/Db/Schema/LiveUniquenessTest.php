<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

use Wio\Schema\NameKey;

/**
 * D-51: names, codes, e-mails, references and links are unique per
 * workspace among records that are not deleted.
 */
final class LiveUniquenessTest extends SchemaTestCase
{
    private string $workspace;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->rows->workspace();
    }

    public function testALabelNameIsUniqueCaseInsensitivelyUntilTheLabelIsDeleted(): void
    {
        $first = $this->rows->label($this->workspace, 'Küche');
        $this->assertRejected(self::DUPLICATE, fn() => $this->rows->label($this->workspace, ' KÜCHE '));

        $this->rows->delete('labels', $first);

        self::assertNotSame('', $this->rows->label($this->workspace, 'Küche'));
    }

    public function testLabelNamesWithAndWithoutUmlautAreDifferent(): void
    {
        $this->rows->label($this->workspace, 'Küche');

        self::assertNotSame('', $this->rows->label($this->workspace, 'Kuche'));
    }

    public function testTheSameLabelNameIsFineInAnotherWorkspace(): void
    {
        $this->rows->label($this->workspace, 'Keller');

        self::assertNotSame('', $this->rows->label($this->rows->workspace(), 'Keller'));
    }

    public function testAPropertyKeyNameIsUniqueUntilDeleted(): void
    {
        $key = fn(): string => $this->rows->insert('property_keys', [
            'workspace_id' => $this->workspace,
            'name' => 'Gewicht',
            'name_key' => NameKey::of('Gewicht'),
            'unit' => 'kg',
        ]);
        $first = $key();
        $this->assertRejected(self::DUPLICATE, $key);

        $this->rows->delete('property_keys', $first);

        self::assertNotSame('', $key());
    }

    public function testAnEntryCodeIsUniqueUntilDeletedAndComparedExactly(): void
    {
        $first = $this->rows->entry($this->workspace, null, ['code' => 'WIO-abc']);
        $this->assertRejected(self::DUPLICATE, fn() => $this->rows->entry($this->workspace, null, ['code' => 'WIO-abc']));
        self::assertNotSame('', $this->rows->entry($this->workspace, null, ['code' => 'WIO-ABC']));

        $this->rows->delete('entries', $first);

        self::assertNotSame('', $this->rows->entry($this->workspace, null, ['code' => 'WIO-abc']));
    }

    public function testManyEntriesMayHaveNoCode(): void
    {
        $this->rows->entry($this->workspace, null);
        $this->rows->entry($this->workspace, null);

        self::assertCount(2, $this->rowsOf('SELECT id FROM entries WHERE code IS NULL'));
    }

    public function testAnExternalReferenceIsUniqueUntilDeleted(): void
    {
        $customer = fn(): string => $this->rows->insert('customers', ['workspace_id' => $this->workspace, 'external_ref' => 'K-1001']);
        $first = $customer();
        $this->assertRejected(self::DUPLICATE, $customer);

        $this->rows->delete('customers', $first);

        self::assertNotSame('', $customer());
    }

    public function testAnEmailIsUniquePerWorkspaceUntilTheUserIsDeleted(): void
    {
        $user = fn(string $email): string => $this->rows->insert('users', [
            'workspace_id' => $this->workspace,
            'role' => 'owner',
            'email' => $email,
            'email_key' => NameKey::of($email),
        ]);
        $first = $user('chef@example.org');
        $this->assertRejected(self::DUPLICATE, fn() => $user('Chef@Example.org'));

        $this->rows->delete('users', $first);

        self::assertNotSame('', $user('chef@example.org'));
    }

    public function testALabelIsLinkedToASubjectOnceUntilTheLinkIsDeleted(): void
    {
        $entry = $this->rows->entry($this->workspace, null);
        $label = $this->rows->label($this->workspace, 'zerbrechlich');
        $link = fn(): string => $this->rows->insert('entity_labels', [
            'workspace_id' => $this->workspace,
            'entity_type' => 'entry',
            'entity_id' => $entry,
            'label_id' => $label,
        ]);
        $first = $link();
        $this->assertRejected(self::DUPLICATE, $link);

        $this->rows->delete('entity_labels', $first);

        self::assertNotSame('', $link());
    }

    public function testASubjectHasOneValuePerPropertyKeyUntilTheValueIsDeleted(): void
    {
        $entry = $this->rows->entry($this->workspace, null);
        $key = $this->rows->insert('property_keys', ['workspace_id' => $this->workspace, 'name' => 'Ziel', 'name_key' => 'ziel']);
        $value = fn(): string => $this->rows->insert('entity_properties', [
            'workspace_id' => $this->workspace,
            'entity_type' => 'entry',
            'entity_id' => $entry,
            'key_id' => $key,
            'value_text' => 'Dachboden',
        ]);
        $first = $value();
        $this->assertRejected(self::DUPLICATE, $value);

        $this->rows->delete('entity_properties', $first);

        self::assertNotSame('', $value());
    }
}
