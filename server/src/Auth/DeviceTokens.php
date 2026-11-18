<?php

declare(strict_types=1);

namespace Wio\Auth;

use DateInterval;
use DateTimeImmutable;
use Psr\Clock\ClockInterface;
use Wio\Database\Sql;
use Wio\Support\Time;
use Wio\Support\Uuid;

/**
 * The server-only table of signed-in devices (D-110, D-111).
 */
final class DeviceTokens
{
    /** A token unused for this long is no longer valid (D-111). */
    public const string IDLE_LIMIT = 'P180D';

    /** last_used_at is written at most this often per token (D-110). */
    public const string TOUCH_INTERVAL = 'PT1H';

    public function __construct(private readonly Sql $sql, private readonly ClockInterface $clock) {}

    /**
     * Creates a token in the caller's transaction and returns it; it is never
     * stored or shown again.
     *
     * @return array{token: string, device_id: string}
     */
    public function create(string $workspaceId, string $userId, string $deviceName): array
    {
        $now = $this->clock->now();
        $token = DeviceToken::generate();
        $deviceId = Uuid::v7($now);
        $this->sql->run(
            'INSERT INTO device_tokens (id, workspace_id, user_id, token_hash, device_name, created_at, last_used_at)
             VALUES (?, ?, ?, ?, ?, ?, ?)',
            [$deviceId, $workspaceId, $userId, DeviceToken::hash($token), $deviceName, Time::toDatabase($now), Time::toDatabase($now)],
        );

        return ['token' => $token, 'device_id' => $deviceId];
    }

    /**
     * The caller behind a token, or null when the token is unknown, idle too
     * long, or its user or workspace is deleted or a helper's link expired.
     */
    public function resolve(#[\SensitiveParameter] string $token): ?AuthContext
    {
        if (!DeviceToken::looksValid($token)) {
            return null;
        }
        $row = $this->sql->row(
            'SELECT t.id, t.workspace_id, t.user_id, t.last_used_at, u.role, u.customer_id, u.expires_at
             FROM device_tokens t
             JOIN users u ON u.workspace_id = t.workspace_id AND u.id = t.user_id AND u.deleted_at IS NULL
             JOIN workspaces w ON w.id = t.workspace_id AND w.deleted_at IS NULL
             WHERE t.token_hash = ?',
            [DeviceToken::hash($token)],
        );
        if ($row === null) {
            return null;
        }

        $now = $this->clock->now();
        $deviceId = Sql::text($row['id']);
        $lastUsed = Time::fromDatabase(Sql::text($row['last_used_at']));
        if ($lastUsed <= $now->sub(new DateInterval(self::IDLE_LIMIT))) {
            $this->sql->run('DELETE FROM device_tokens WHERE id = ?', [$deviceId]);

            return null;
        }
        $expiresAt = Sql::textOrNull($row['expires_at']);
        if ($expiresAt !== null && Time::fromDatabase($expiresAt) <= $now) {
            return null;
        }
        if ($lastUsed <= $now->sub(new DateInterval(self::TOUCH_INTERVAL))) {
            $this->sql->run('UPDATE device_tokens SET last_used_at = ? WHERE id = ?', [Time::toDatabase($now), $deviceId]);
        }

        return new AuthContext(
            Sql::text($row['workspace_id']),
            Sql::text($row['user_id']),
            Sql::text($row['role']),
            Sql::textOrNull($row['customer_id']),
            $deviceId,
        );
    }

    /**
     * The user's valid devices, newest first.
     *
     * @return list<array{id: string, device_name: string, created_at: DateTimeImmutable, last_used_at: DateTimeImmutable}>
     */
    public function listFor(string $workspaceId, string $userId): array
    {
        $idleSince = $this->clock->now()->sub(new DateInterval(self::IDLE_LIMIT));
        $devices = [];
        foreach ($this->sql->rows(
            'SELECT id, device_name, created_at, last_used_at FROM device_tokens
             WHERE workspace_id = ? AND user_id = ? AND last_used_at > ?
             ORDER BY created_at DESC, id DESC',
            [$workspaceId, $userId, Time::toDatabase($idleSince)],
        ) as $row) {
            $devices[] = [
                'id' => Sql::text($row['id']),
                'device_name' => Sql::text($row['device_name']),
                'created_at' => Time::fromDatabase(Sql::text($row['created_at'])),
                'last_used_at' => Time::fromDatabase(Sql::text($row['last_used_at'])),
            ];
        }

        return $devices;
    }

    /**
     * Deletes one of the user's devices; false when it is not theirs.
     */
    public function delete(string $workspaceId, string $userId, string $deviceId): bool
    {
        return $this->sql->run(
            'DELETE FROM device_tokens WHERE id = ? AND workspace_id = ? AND user_id = ?',
            [$deviceId, $workspaceId, $userId],
        )->rowCount() === 1;
    }

    public function deleteAllOf(string $workspaceId, string $userId): int
    {
        return $this->sql->run(
            'DELETE FROM device_tokens WHERE workspace_id = ? AND user_id = ?',
            [$workspaceId, $userId],
        )->rowCount();
    }
}
