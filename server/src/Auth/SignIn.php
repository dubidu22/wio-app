<?php

declare(strict_types=1);

namespace Wio\Auth;

use Psr\Clock\ClockInterface;
use Wio\Database\Sql;
use Wio\Schema\NameKey;
use Wio\Support\Time;

/**
 * Owner sign-in with e-mail and password (D-108 to D-114). Only owners have
 * passwords in M1; customers and helpers sign in by link in M6.
 */
final class SignIn
{
    /** More owners than this with one e-mail is refused, not guessed at. */
    public const int MAX_ACCOUNTS = 10;

    /**
     * @param \Closure(string): void $log one line to the error log, never a password
     */
    public function __construct(
        private readonly Sql $sql,
        private readonly ClockInterface $clock,
        private readonly PasswordHashing $hasher,
        private readonly SignInLimiter $limiter,
        private readonly DeviceTokens $tokens,
        private readonly \Closure $log,
    ) {}

    public function attempt(
        string $email,
        #[\SensitiveParameter]
        string $password,
        string $deviceName,
        ?string $workspaceId,
        string $ip,
    ): SignInResult {
        $emailHash = SignInLimiter::emailHash($email);
        $ipHash = SignInLimiter::ipHash($ip);

        $this->limiter->purge();
        // Reserve before checking (D-113): parallel attempts see each other.
        $reserved = $this->limiter->reserve($emailHash, $ipHash);
        if ($this->limiter->exceeded($emailHash, $ipHash)) {
            $this->limiter->release($reserved);

            return SignInResult::limited($this->limiter->retryAfter($emailHash, $ipHash) ?? 1);
        }

        $accounts = $this->accounts(NameKey::of($email), $workspaceId);
        if (\count($accounts) > self::MAX_ACCOUNTS) {
            ($this->log)(sprintf('wio sign-in: more than %d owner accounts share one e-mail key; refused.', self::MAX_ACCOUNTS));
            $accounts = [];
        }

        $matches = [];
        foreach ($accounts as $account) {
            if ($this->hasher->verify($password, $account['password_hash'])) {
                $matches[] = $account;
            }
        }
        if ($accounts === []) {
            $this->hasher->spendOneCheck($password);
        }

        if ($matches === []) {
            // The reserved row stays as the failure.
            return SignInResult::invalid();
        }
        if (\count($matches) > 1) {
            $this->limiter->release($reserved);

            return SignInResult::choose(array_map(
                static fn(array $account): array => ['id' => $account['workspace_id'], 'name' => $account['workspace_name']],
                $matches,
            ));
        }

        $account = $matches[0];

        return SignInResult::signedIn($this->sql->transaction(function () use ($account, $password, $deviceName, $emailHash): array {
            if ($this->hasher->needsRehash($account['password_hash'])) {
                $this->sql->run(
                    'UPDATE user_passwords SET password_hash = ?, changed_at = ? WHERE workspace_id = ? AND user_id = ?',
                    [$this->hasher->hash($password), Time::toDatabase($this->clock->now()), $account['workspace_id'], $account['user_id']],
                );
            }
            // Clears this attempt's reserved row with the e-mail key's failures.
            $this->limiter->clear($emailHash);
            $device = $this->tokens->create($account['workspace_id'], $account['user_id'], $deviceName);

            return [
                'token' => $device['token'],
                'device_id' => $device['device_id'],
                'user' => ['id' => $account['user_id'], 'role' => $account['role'], 'display_name' => $account['display_name']],
                'workspace' => ['id' => $account['workspace_id'], 'name' => $account['workspace_name'], 'plan' => $account['plan']],
            ];
        }));
    }

    /**
     * Live owners with this e-mail key in live workspaces, with a password.
     *
     * @return list<array{workspace_id: string, user_id: string, role: string, display_name: ?string, workspace_name: ?string, plan: string, password_hash: string}>
     */
    private function accounts(string $emailKey, ?string $workspaceId): array
    {
        $sql = 'SELECT u.workspace_id, u.id AS user_id, u.role, u.display_name, w.name AS workspace_name, w.plan, p.password_hash
                FROM users u
                JOIN workspaces w ON w.id = u.workspace_id AND w.deleted_at IS NULL
                JOIN user_passwords p ON p.workspace_id = u.workspace_id AND p.user_id = u.id
                WHERE u.email_key = ? AND u.role = \'owner\' AND u.deleted_at IS NULL';
        $values = [$emailKey];
        if ($workspaceId !== null) {
            $sql .= ' AND u.workspace_id = ?';
            $values[] = $workspaceId;
        }
        $sql .= ' ORDER BY w.name, u.workspace_id LIMIT ' . (self::MAX_ACCOUNTS + 1);

        $accounts = [];
        foreach ($this->sql->rows($sql, $values) as $row) {
            $accounts[] = [
                'workspace_id' => Sql::text($row['workspace_id']),
                'user_id' => Sql::text($row['user_id']),
                'role' => Sql::text($row['role']),
                'display_name' => Sql::textOrNull($row['display_name']),
                'workspace_name' => Sql::textOrNull($row['workspace_name']),
                'plan' => Sql::text($row['plan']),
                'password_hash' => Sql::text($row['password_hash']),
            ];
        }

        return $accounts;
    }
}
