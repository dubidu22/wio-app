<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

use PDO;
use PDOStatement;
use RuntimeException;
use Wio\Schema\NameKey;

/**
 * Inserts rows with the common fields filled in, for schema tests. Every
 * value is invented test data.
 */
final class Rows
{
    private const string TIME = '2026-01-05 09:00:00.000';

    public function __construct(private readonly PDO $pdo) {}

    public static function uuid(): string
    {
        $hex = bin2hex(random_bytes(16));

        return sprintf(
            '%s-%s-7%s-8%s-%s',
            substr($hex, 0, 8),
            substr($hex, 8, 4),
            substr($hex, 13, 3),
            substr($hex, 17, 3),
            substr($hex, 20, 12),
        );
    }

    /**
     * @param array<string, scalar|null> $values
     */
    public function insert(string $table, array $values, bool $common = true): string
    {
        if ($common) {
            $values += [
                'id' => self::uuid(),
                'created_at' => self::TIME,
                'updated_at' => self::TIME,
                'revision' => 1,
            ];
        }
        $columns = array_keys($values);
        $sql = sprintf(
            'INSERT INTO %s (%s) VALUES (%s)',
            $table,
            implode(', ', $columns),
            implode(', ', array_fill(0, count($columns), '?')),
        );
        $this->prepare($sql)->execute(array_values($values));

        return is_string($values['id'] ?? null) ? $values['id'] : '';
    }

    public function workspace(string $plan = 'professional'): string
    {
        return $this->insert('workspaces', ['name' => 'Testraum', 'plan' => $plan]);
    }

    public function customer(string $workspace): string
    {
        return $this->insert('customers', ['workspace_id' => $workspace, 'name' => 'Familie Beispiel']);
    }

    public function site(string $workspace, ?string $customer): string
    {
        return $this->insert('sites', [
            'workspace_id' => $workspace,
            'customer_id' => $customer,
            'name' => 'Altbau',
            'address' => 'Musterweg 1, 12345 Beispielstadt',
        ]);
    }

    public function room(string $workspace, string $site, ?string $customer): string
    {
        return $this->insert('rooms', [
            'workspace_id' => $workspace,
            'customer_id' => $customer,
            'site_id' => $site,
            'name' => 'Keller',
        ]);
    }

    public function fixture(string $workspace, string $room, ?string $customer): string
    {
        return $this->insert('fixtures', [
            'workspace_id' => $workspace,
            'customer_id' => $customer,
            'room_id' => $room,
            'name' => 'Regal',
            'levels' => '[{"height_cm":40,"compartments":2}]',
        ]);
    }

    /**
     * @param array<string, scalar|null> $values
     */
    public function entry(string $workspace, ?string $customer, array $values = []): string
    {
        return $this->insert('entries', $values + ['workspace_id' => $workspace, 'customer_id' => $customer]);
    }

    /**
     * @param array<string, scalar|null> $values
     */
    public function picture(string $workspace, ?string $customer, array $values = []): string
    {
        return $this->insert('pictures', $values + [
            'workspace_id' => $workspace,
            'customer_id' => $customer,
            'file_sha256' => str_repeat('ab', 32),
            'file_bytes' => 1000,
            'file_mime' => 'image/jpeg',
            'width_px' => 800,
            'height_px' => 600,
        ]);
    }

    public function job(string $workspace, string $customer): string
    {
        return $this->insert('jobs', ['workspace_id' => $workspace, 'customer_id' => $customer, 'date' => '2026-01-05']);
    }

    public function label(string $workspace, string $name): string
    {
        return $this->insert('labels', ['workspace_id' => $workspace, 'name' => $name, 'name_key' => NameKey::of($name)]);
    }

    public function user(string $workspace, string $role = 'owner', ?string $customer = null): string
    {
        return $this->insert('users', [
            'workspace_id' => $workspace,
            'customer_id' => $customer,
            'role' => $role,
            'expires_at' => $role === 'helper' ? '2026-02-01 00:00:00.000' : null,
        ]);
    }

    public function delete(string $table, string $id): void
    {
        $this->prepare("UPDATE {$table} SET deleted_at = '2026-01-06 00:00:00.000' WHERE id = ?")->execute([$id]);
    }

    private function prepare(string $sql): PDOStatement
    {
        $statement = $this->pdo->prepare($sql);
        if ($statement === false) {
            throw new RuntimeException('Cannot prepare: ' . $sql);
        }

        return $statement;
    }
}
