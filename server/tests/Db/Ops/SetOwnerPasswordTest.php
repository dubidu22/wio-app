<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Ops;

use PHPUnit\Framework\TestCase;
use Wio\Auth\PasswordHasher;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Ops\OpsException;
use Wio\Ops\SetOwnerPassword;
use Wio\Tests\Support\AuthFixtures;
use Wio\Tests\Support\FrozenClock;
use Wio\Tests\Support\MigratedDatabase;

/**
 * bin/set-owner-password's class (D-115), plan 005 test T12.
 */
final class SetOwnerPasswordTest extends TestCase
{
    private const string NEW_PASSWORD = 'ein-neues-langes-passwort';

    private Sql $sql;
    private AuthFixtures $fixtures;
    private SetOwnerPassword $set;

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
        $clock = new FrozenClock();
        $this->fixtures = new AuthFixtures($this->sql, $clock);
        $this->set = new SetOwnerPassword($this->sql, $clock, new PasswordHasher(PasswordHasher::LOWEST));
    }

    public function testItReplacesThePasswordAndKeepsDevicesUnlessAsked(): void
    {
        $workspace = $this->fixtures->workspace();
        $owner = $this->fixtures->user($workspace);
        $this->fixtures->token($workspace, $owner);

        $result = $this->set->run('INHABER@example.org', null, self::NEW_PASSWORD, false);

        self::assertSame(['workspace_id' => $workspace, 'user_id' => $owner, 'revoked_devices' => 0], $result);
        self::assertTrue(password_verify(self::NEW_PASSWORD, $this->hash($owner)));
        self::assertSame(1, $this->fixtures->count('device_tokens'));

        $again = $this->set->run('inhaber@example.org', null, self::NEW_PASSWORD, true);
        self::assertSame(1, $again['revoked_devices']);
        self::assertSame(0, $this->fixtures->count('device_tokens'));
    }

    public function testItSetsAFirstPasswordForAnOwnerWithoutOne(): void
    {
        $workspace = $this->fixtures->workspace();
        $owner = $this->fixtures->user($workspace, password: null);

        $this->set->run('inhaber@example.org', null, self::NEW_PASSWORD, false);

        self::assertTrue(password_verify(self::NEW_PASSWORD, $this->hash($owner)));
    }

    public function testSeveralWorkspacesNeedAWorkspaceId(): void
    {
        $home = $this->fixtures->workspace('Zuhause', 'personal');
        $business = $this->fixtures->workspace('Betrieb');
        $this->fixtures->user($home);
        $owner = $this->fixtures->user($business);

        try {
            $this->set->run('inhaber@example.org', null, self::NEW_PASSWORD, false);
            self::fail('guessed a workspace');
        } catch (OpsException $e) {
            self::assertStringContainsString($home, $e->getMessage());
            self::assertStringContainsString($business, $e->getMessage());
            self::assertStringNotContainsString('Betrieb', $e->getMessage(), 'only ids, no names');
        }

        $this->set->run('inhaber@example.org', $business, self::NEW_PASSWORD, false);
        self::assertTrue(password_verify(self::NEW_PASSWORD, $this->hash($owner)));
    }

    public function testItRefusesUnknownEMailsCustomersAndShortPasswords(): void
    {
        $workspace = $this->fixtures->workspace();
        $this->fixtures->user($workspace);
        $this->fixtures->user($workspace, 'customer', 'kunde@example.org');

        foreach ([['niemand@example.org', self::NEW_PASSWORD], ['kunde@example.org', self::NEW_PASSWORD], ['inhaber@example.org', 'kurz']] as [$email, $password]) {
            try {
                $this->set->run($email, null, $password, false);
                self::fail('accepted ' . $email);
            } catch (OpsException $e) {
                self::assertStringNotContainsString($password, $e->getMessage());
            }
        }
    }

    private function hash(string $userId): string
    {
        $hash = $this->sql->run('SELECT password_hash FROM user_passwords WHERE user_id = ?', [$userId])->fetchColumn();
        self::assertIsString($hash);

        return $hash;
    }
}
