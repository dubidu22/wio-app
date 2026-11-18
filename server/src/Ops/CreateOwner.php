<?php

declare(strict_types=1);

namespace Wio\Ops;

use Psr\Clock\ClockInterface;
use RuntimeException;
use Wio\Auth\PasswordHasher;
use Wio\Database\Sql;
use Wio\Schema\NameKey;
use Wio\Schema\RevisionCounter;
use Wio\Support\Time;
use Wio\Support\Uuid;

/**
 * Creates a workspace, its revision counter, its owner and the owner's
 * password in one transaction (D-115). Reached by bin/create-owner, and later
 * by #10's ops endpoint if the hosting has no SSH (O-6).
 */
final class CreateOwner
{
    public function __construct(
        private readonly Sql $sql,
        private readonly ClockInterface $clock,
        private readonly PasswordHasher $hasher,
    ) {}

    /**
     * @return array{workspace_id: string, user_id: string}
     */
    public function run(
        string $workspaceName,
        string $plan,
        string $email,
        ?string $displayName,
        #[\SensitiveParameter]
        string $password,
    ): array {
        if (!\in_array($plan, ['personal', 'professional'], true)) {
            throw new OpsException('The plan must be personal or professional.');
        }
        if (trim($email) === '' || mb_strlen($email, 'UTF-8') > 254 || !str_contains($email, '@')) {
            throw new OpsException('The e-mail address is not valid.');
        }
        OwnerPassword::check($password);
        $hash = $this->hasher->hash($password);

        return $this->sql->transaction(function () use ($workspaceName, $plan, $email, $displayName, $hash): array {
            $now = $this->clock->now();
            $time = Time::toDatabase($now);
            $workspaceId = Uuid::v7($now);
            $userId = Uuid::v7($now);
            $revisions = new RevisionCounter($this->sql->pdo);

            // The workspace row must exist before its counter (foreign key);
            // its revision is the counter's first one.
            $this->sql->run(
                'INSERT INTO workspaces (id, name, plan, created_at, updated_at, revision) VALUES (?, ?, ?, ?, ?, 1)',
                [$workspaceId, $workspaceName === '' ? null : $workspaceName, $plan, $time, $time],
            );
            $revisions->start($workspaceId);
            if ($revisions->next($workspaceId) !== 1) {
                throw new RuntimeException('A new workspace must start at revision 1.');
            }

            $this->sql->run(
                'INSERT INTO users (id, workspace_id, customer_id, role, display_name, email, email_key, created_at, updated_at, revision)
                 VALUES (?, ?, NULL, \'owner\', ?, ?, ?, ?, ?, ?)',
                [$userId, $workspaceId, $displayName, $email, NameKey::of($email), $time, $time, $revisions->next($workspaceId)],
            );
            $this->sql->run(
                'INSERT INTO user_passwords (workspace_id, user_id, password_hash, changed_at) VALUES (?, ?, ?, ?)',
                [$workspaceId, $userId, $hash, $time],
            );

            return ['workspace_id' => $workspaceId, 'user_id' => $userId];
        });
    }
}
