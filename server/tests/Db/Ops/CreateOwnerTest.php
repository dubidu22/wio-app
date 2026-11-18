<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Ops;

use PHPUnit\Framework\TestCase;
use Wio\Auth\PasswordHasher;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Ops\CreateOwner;
use Wio\Ops\OpsException;
use Wio\Tests\Support\FrozenClock;
use Wio\Tests\Support\MigratedDatabase;

/**
 * bin/create-owner's class (D-115), plan 005 test T12.
 */
final class CreateOwnerTest extends TestCase
{
    private const string PASSWORD = 'ein-langes-passwort';

    private Sql $sql;
    private CreateOwner $create;

    public static function setUpBeforeClass(): void
    {
        MigratedDatabase::migrate();
    }

    public static function tearDownAfterClass(): void
    {
        MigratedDatabase::drop();
    }

    protected function setUp(): void
    {
        $this->sql = new Sql(Connection::fromEnvironment());
        MigratedDatabase::empty($this->sql->pdo);
        $this->create = new CreateOwner($this->sql, new FrozenClock(), new PasswordHasher(PasswordHasher::LOWEST));
    }

    public function testItCreatesTheWorkspaceItsCounterTheOwnerAndThePassword(): void
    {
        $ids = $this->create->run('Umzüge Beispiel', 'professional', 'Inhaber@Example.org', 'Inhaber Beispiel', self::PASSWORD);

        self::assertSame(
            [['id' => $ids['workspace_id'], 'name' => 'Umzüge Beispiel', 'plan' => 'professional', 'revision' => 1, 'created_at' => '2026-11-18 10:00:00.000']],
            $this->sql->rows('SELECT id, name, plan, revision, created_at FROM workspaces'),
        );
        self::assertSame(
            [['workspace_id' => $ids['workspace_id'], 'last_revision' => 2]],
            $this->sql->rows('SELECT workspace_id, last_revision FROM workspace_counters'),
        );
        self::assertSame(
            [['id' => $ids['user_id'], 'role' => 'owner', 'customer_id' => null, 'display_name' => 'Inhaber Beispiel',
                'email' => 'Inhaber@Example.org', 'email_key' => 'inhaber@example.org', 'revision' => 2]],
            $this->sql->rows('SELECT id, role, customer_id, display_name, email, email_key, revision FROM users'),
        );
        $hash = $this->sql->run('SELECT password_hash FROM user_passwords WHERE user_id = ?', [$ids['user_id']])->fetchColumn();
        self::assertIsString($hash);
        self::assertStringStartsWith('$argon2id$', $hash);
        self::assertTrue(password_verify(self::PASSWORD, $hash));
        self::assertMatchesRegularExpression('/^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/', $ids['workspace_id']);
    }

    public function testTheSameEMailMayOwnASecondWorkspace(): void
    {
        $this->create->run('Zuhause', 'personal', 'inhaber@example.org', null, self::PASSWORD);
        $this->create->run('Betrieb', 'professional', 'inhaber@example.org', null, self::PASSWORD);

        self::assertSame(2, $this->sql->run('SELECT COUNT(*) FROM users')->fetchColumn());
    }

    public function testItRefusesAShortPasswordAndABadPlanOrEMail(): void
    {
        foreach ([
            ['Betrieb', 'professional', 'inhaber@example.org', 'kurz'],
            ['Betrieb', 'business', 'inhaber@example.org', self::PASSWORD],
            ['Betrieb', 'professional', 'kein-at-zeichen', self::PASSWORD],
        ] as [$name, $plan, $email, $password]) {
            try {
                $this->create->run($name, $plan, $email, null, $password);
                self::fail('accepted: ' . $plan . ' ' . $email);
            } catch (OpsException $e) {
                self::assertStringNotContainsString($password, $e->getMessage());
            }
        }
        self::assertSame(0, $this->sql->run('SELECT COUNT(*) FROM workspaces')->fetchColumn());
    }

    public function testAFailureLeavesNothingBehind(): void
    {
        try {
            // A display name longer than the column fails in strict mode (D-53).
            $this->create->run('Betrieb', 'professional', 'inhaber@example.org', str_repeat('x', 201), self::PASSWORD);
            self::fail('accepted a 201-character display name');
        } catch (\PDOException) {
        }

        foreach (['workspaces', 'workspace_counters', 'users', 'user_passwords'] as $table) {
            self::assertSame(0, $this->sql->run("SELECT COUNT(*) FROM {$table}")->fetchColumn(), $table);
        }
    }
}
