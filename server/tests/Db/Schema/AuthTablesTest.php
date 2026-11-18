<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

/**
 * The server-only auth tables (D-109, D-110, D-113), plan 005 test T1: a
 * password or token can never point at a user of another workspace (D-49).
 */
final class AuthTablesTest extends SchemaTestCase
{
    private const string HASH = 'a3f1c2d4e5b6978899aabbccddeeff00112233445566778899aabbccddeeff00';

    public function testAPasswordBelongsToAUserOfItsOwnWorkspace(): void
    {
        $workspace = $this->rows->workspace();
        $user = $this->rows->user($workspace);
        $other = $this->rows->workspace();

        $this->password($workspace, $user);
        self::assertCount(1, $this->rowsOf('SELECT * FROM user_passwords'));
        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->password($other, $user));
    }

    public function testATokenBelongsToAUserOfItsOwnWorkspace(): void
    {
        $workspace = $this->rows->workspace();
        $user = $this->rows->user($workspace);
        $other = $this->rows->workspace();

        $this->token($workspace, $user, self::HASH);
        $this->assertRejected(self::FOREIGN_KEY, fn() => $this->token($other, $user, str_replace('a', 'b', self::HASH)));
    }

    public function testATokenHashIsSixtyFourLowerCaseHexDigits(): void
    {
        $workspace = $this->rows->workspace();
        $user = $this->rows->user($workspace);

        $this->assertRejected(self::CHECK, fn() => $this->token($workspace, $user, strtoupper(self::HASH)));
        $this->assertRejected(self::CHECK, fn() => $this->token($workspace, $user, 'wio_plain-token'));
    }

    public function testATokenHashIsUnique(): void
    {
        $workspace = $this->rows->workspace();
        $user = $this->rows->user($workspace);

        $this->token($workspace, $user, self::HASH);
        $this->assertRejected(self::DUPLICATE, fn() => $this->token($workspace, $user, self::HASH));
    }

    private function password(string $workspace, string $user): void
    {
        $this->rows->insert('user_passwords', [
            'workspace_id' => $workspace,
            'user_id' => $user,
            'password_hash' => '$argon2id$v=19$m=8,t=1,p=1$x$y',
            'changed_at' => '2026-11-18 10:00:00.000',
        ], false);
    }

    private function token(string $workspace, string $user, string $hash): void
    {
        $this->rows->insert('device_tokens', [
            'id' => Rows::uuid(),
            'workspace_id' => $workspace,
            'user_id' => $user,
            'token_hash' => $hash,
            'device_name' => 'Testgerät',
            'created_at' => '2026-11-18 10:00:00.000',
            'last_used_at' => '2026-11-18 10:00:00.000',
        ], false);
    }
}
