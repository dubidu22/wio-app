<?php

declare(strict_types=1);

namespace Wio\Tests\Support;

use Psr\Clock\ClockInterface;
use Wio\Auth\DeviceTokens;
use Wio\Auth\PasswordHasher;
use Wio\Database\Sql;
use Wio\Schema\NameKey;
use Wio\Support\Time;
use Wio\Tests\Db\Schema\Rows;

/**
 * Workspaces, users, passwords and tokens for auth tests. Every value is
 * invented (example.org).
 */
final class AuthFixtures
{
    public const string PASSWORD = 'richtig-geheim-123';

    private readonly Rows $rows;

    public function __construct(
        private readonly Sql $sql,
        private readonly ClockInterface $clock,
        private readonly PasswordHasher $hasher = new PasswordHasher(PasswordHasher::LOWEST),
    ) {
        $this->rows = new Rows($sql->pdo);
    }

    public function workspace(string $name = 'Testraum', string $plan = 'professional'): string
    {
        return $this->rows->insert('workspaces', ['name' => $name, 'plan' => $plan]);
    }

    public function customer(string $workspaceId): string
    {
        return $this->rows->customer($workspaceId);
    }

    /**
     * A user of any role, with a password when one is given (only owners
     * get one in production; the test may give others one to prove that
     * they still cannot sign in).
     */
    public function user(
        string $workspaceId,
        string $role = 'owner',
        ?string $email = 'inhaber@example.org',
        ?string $password = self::PASSWORD,
        ?string $customerId = null,
        ?string $expiresAt = null,
    ): string {
        if ($role !== 'owner' && $customerId === null) {
            $customerId = $this->customer($workspaceId);
        }
        $userId = $this->rows->insert('users', [
            'workspace_id' => $workspaceId,
            'customer_id' => $customerId,
            'role' => $role,
            'display_name' => 'Inhaber Beispiel',
            'email' => $email,
            'email_key' => $email === null ? null : NameKey::of($email),
            'expires_at' => $role === 'helper' ? ($expiresAt ?? '2027-01-01 00:00:00.000') : null,
        ]);
        if ($password !== null) {
            $this->sql->run(
                'INSERT INTO user_passwords (workspace_id, user_id, password_hash, changed_at) VALUES (?, ?, ?, ?)',
                [$workspaceId, $userId, $this->hasher->hash($password), Time::toDatabase($this->clock->now())],
            );
        }

        return $userId;
    }

    /**
     * @return array{token: string, device_id: string}
     */
    public function token(string $workspaceId, string $userId, string $deviceName = 'Testgerät'): array
    {
        return (new DeviceTokens($this->sql, $this->clock))->create($workspaceId, $userId, $deviceName);
    }

    public function delete(string $table, string $id): void
    {
        $this->rows->delete($table, $id);
    }

    public function count(string $table): int
    {
        $value = $this->sql->run('SELECT COUNT(*) FROM `' . str_replace('`', '``', $table) . '`')->fetchColumn();

        return is_numeric($value) ? (int) $value : -1;
    }
}
