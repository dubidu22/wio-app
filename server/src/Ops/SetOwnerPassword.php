<?php

declare(strict_types=1);

namespace Wio\Ops;

use Psr\Clock\ClockInterface;
use Wio\Auth\DeviceTokens;
use Wio\Auth\PasswordHasher;
use Wio\Database\Sql;
use Wio\Schema\NameKey;
use Wio\Support\Time;

/**
 * Sets a live owner's password, for example after it was lost (no reset
 * e-mail in M1, D-115), and can sign out all of that owner's devices.
 */
final class SetOwnerPassword
{
    public function __construct(
        private readonly Sql $sql,
        private readonly ClockInterface $clock,
        private readonly PasswordHasher $hasher,
    ) {}

    /**
     * @return array{workspace_id: string, user_id: string, revoked_devices: int}
     */
    public function run(string $email, ?string $workspaceId, #[\SensitiveParameter] string $password, bool $revokeDevices): array
    {
        OwnerPassword::check($password);

        $sql = 'SELECT u.workspace_id, u.id FROM users u JOIN workspaces w ON w.id = u.workspace_id AND w.deleted_at IS NULL
                WHERE u.email_key = ? AND u.role = \'owner\' AND u.deleted_at IS NULL';
        $values = [NameKey::of($email)];
        if ($workspaceId !== null) {
            $sql .= ' AND u.workspace_id = ?';
            $values[] = $workspaceId;
        }
        $owners = $this->sql->rows($sql . ' ORDER BY u.workspace_id', $values);
        if ($owners === []) {
            throw new OpsException('No live owner has this e-mail address' . ($workspaceId === null ? '.' : ' in that workspace.'));
        }
        if (\count($owners) > 1) {
            throw new OpsException('Several workspaces have an owner with this e-mail address; pass --workspace-id with one of: '
                . implode(', ', array_map(static fn(array $owner): string => Sql::text($owner['workspace_id']), $owners)));
        }

        $owner = ['workspace_id' => Sql::text($owners[0]['workspace_id']), 'user_id' => Sql::text($owners[0]['id'])];
        $hash = $this->hasher->hash($password);

        return $this->sql->transaction(function () use ($owner, $hash, $revokeDevices): array {
            $this->sql->run(
                'INSERT INTO user_passwords (workspace_id, user_id, password_hash, changed_at) VALUES (?, ?, ?, ?)
                 ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash), changed_at = VALUES(changed_at)',
                [$owner['workspace_id'], $owner['user_id'], $hash, Time::toDatabase($this->clock->now())],
            );
            $revoked = $revokeDevices
                ? (new DeviceTokens($this->sql, $this->clock))->deleteAllOf($owner['workspace_id'], $owner['user_id'])
                : 0;

            return $owner + ['revoked_devices' => $revoked];
        });
    }
}
