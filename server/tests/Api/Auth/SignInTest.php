<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Auth;

use Wio\Auth\DeviceToken;
use Wio\Auth\PasswordHasher;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;
use Wio\Tests\Support\AuthFixtures;

/**
 * Owner sign-in (D-108 to D-114), plan 005 tests T2, T3, T5 and T8.
 */
#[Operation('signIn')]
#[Operation('getMe')]
final class SignInTest extends DatabaseTestCase
{
    public function testAnOwnerSignsInAndGetsADeviceToken(): void
    {
        $workspace = $this->fixtures->workspace('Umzüge Beispiel');
        $user = $this->fixtures->user($workspace);

        $response = $this->signIn(self::credentials());

        self::assertSame(200, $response->getStatusCode());
        $body = self::json($response);
        $token = $body['token'];
        self::assertIsString($token);
        self::assertTrue(DeviceToken::looksValid($token), 'wio_ + 43 base64url characters');
        self::assertSame(47, \strlen($token));
        self::assertSame(['id' => $user, 'role' => 'owner', 'display_name' => 'Inhaber Beispiel'], $body['user']);
        self::assertSame(['id' => $workspace, 'name' => 'Umzüge Beispiel', 'plan' => 'professional'], $body['workspace']);

        $stored = $this->sql->rows('SELECT id, token_hash, device_name FROM device_tokens');
        self::assertSame([['id' => $body['device_id'], 'token_hash' => hash('sha256', $token), 'device_name' => 'Pixel Test']], $stored);
        self::assertStringNotContainsString($token, json_encode($this->sql->rows('SELECT * FROM device_tokens'), JSON_THROW_ON_ERROR));

        $me = $this->send($this->call('GET', '/auth/me', token: $token));
        self::assertSame(200, $me->getStatusCode());
        self::assertSame($body['device_id'], self::json($me)['device_id']);
    }

    public function testEachSignInIsItsOwnDevice(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        $first = self::json($this->signIn(self::credentials()));
        $second = self::json($this->signIn(self::credentials()));

        self::assertNotSame($first['token'], $second['token']);
        self::assertNotSame($first['device_id'], $second['device_id']);
        self::assertSame(2, $this->fixtures->count('device_tokens'));
    }

    public function testTheEMailIsComparedByItsKey(): void
    {
        $this->fixtures->user($this->fixtures->workspace(), email: 'Inhaber@Example.org');

        self::assertSame(200, $this->signIn(self::credentials(' inhaber@EXAMPLE.org '))->getStatusCode());
    }

    public function testAWrongPasswordAndAnUnknownEMailGetTheSameAnswer(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        $wrong = $this->signIn(self::credentials(password: 'falsch'));
        $unknown = $this->signIn(self::credentials('niemand@example.org'));

        self::assertProblem($wrong, 401, 'invalid_credentials');
        self::assertProblem($unknown, 401, 'invalid_credentials');
        self::assertSame((string) $wrong->getBody(), (string) $unknown->getBody());
        self::assertSame(2, $this->fixtures->count('sign_in_failures'));
        self::assertSame(0, $this->fixtures->count('device_tokens'));
    }

    public function testOnlyOwnersSignInWithAPassword(): void
    {
        $workspace = $this->fixtures->workspace();
        $this->fixtures->user($workspace, 'customer', 'kunde@example.org');
        $this->fixtures->user($workspace, 'helper', 'helfer@example.org');

        self::assertProblem($this->signIn(self::credentials('kunde@example.org')), 401, 'invalid_credentials');
        self::assertProblem($this->signIn(self::credentials('helfer@example.org')), 401, 'invalid_credentials');
    }

    public function testDeletedUsersAndWorkspacesCannotSignIn(): void
    {
        $workspace = $this->fixtures->workspace();
        $this->fixtures->delete('users', $this->fixtures->user($workspace));
        $gone = $this->fixtures->workspace();
        $this->fixtures->user($gone, email: 'zwei@example.org');
        $this->fixtures->delete('workspaces', $gone);

        self::assertProblem($this->signIn(self::credentials()), 401, 'invalid_credentials');
        self::assertProblem($this->signIn(self::credentials('zwei@example.org')), 401, 'invalid_credentials');
    }

    public function testOneEMailInTwoWorkspacesAsksWhichOne(): void
    {
        $home = $this->fixtures->workspace('Zuhause', 'personal');
        $business = $this->fixtures->workspace('Betrieb');
        $this->fixtures->user($home);
        $this->fixtures->user($business);

        $response = $this->signIn(self::credentials());

        self::assertProblem($response, 409, 'workspace_choice_required');
        self::assertSame(
            [['id' => $business, 'name' => 'Betrieb'], ['id' => $home, 'name' => 'Zuhause']],
            self::json($response)['workspaces'],
        );
        self::assertSame(0, $this->fixtures->count('sign_in_failures'), 'a 409 is not a failure');
        self::assertSame(0, $this->fixtures->count('device_tokens'));

        $chosen = $this->signIn(self::credentials() + ['workspace_id' => $home]);
        self::assertSame(200, $chosen->getStatusCode());
        self::assertSame($home, self::workspaceOf($chosen));
    }

    public function testOnlyWorkspacesWhosePasswordMatchedAreNamed(): void
    {
        $home = $this->fixtures->workspace('Zuhause', 'personal');
        $business = $this->fixtures->workspace('Betrieb');
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $this->fixtures->user($home, password: 'ein-anderes-passwort');
        $this->fixtures->user($business);

        $response = $this->signIn(self::credentials());
        self::assertSame(200, $response->getStatusCode(), 'one match signs in at once');
        self::assertSame($business, self::workspaceOf($response));

        $this->fixtures->user($other);
        $choice = self::json($this->signIn(self::credentials()));
        self::assertSame([['id' => $other, 'name' => 'Anderer Betrieb'], ['id' => $business, 'name' => 'Betrieb']], $choice['workspaces']);
    }

    public function testAChosenWorkspaceChecksOnlyThatPassword(): void
    {
        $home = $this->fixtures->workspace('Zuhause', 'personal');
        $business = $this->fixtures->workspace('Betrieb');
        $this->fixtures->user($home, password: 'ein-anderes-passwort');
        $this->fixtures->user($business);

        self::assertProblem($this->signIn(self::credentials() + ['workspace_id' => $home]), 401, 'invalid_credentials');
        self::assertSame(200, $this->signIn(self::credentials() + ['workspace_id' => $business])->getStatusCode());
    }

    private static function workspaceOf(\Psr\Http\Message\ResponseInterface $response): mixed
    {
        $workspace = self::json($response)['workspace'] ?? null;
        self::assertIsArray($workspace);

        return $workspace['id'] ?? null;
    }

    public function testAWeakerHashIsUpgradedAtSignIn(): void
    {
        $workspace = $this->fixtures->workspace();
        $user = $this->fixtures->user($workspace);
        $weaker = password_hash(AuthFixtures::PASSWORD, PASSWORD_ARGON2ID, ['memory_cost' => 16, 'time_cost' => 1, 'threads' => 1]);
        $this->sql->run('UPDATE user_passwords SET password_hash = ? WHERE user_id = ?', [$weaker, $user]);

        self::assertSame(200, $this->signIn(self::credentials())->getStatusCode());

        $hash = $this->sql->run('SELECT password_hash FROM user_passwords WHERE user_id = ?', [$user])->fetchColumn();
        self::assertIsString($hash);
        self::assertNotSame($weaker, $hash);
        self::assertFalse((new PasswordHasher(PasswordHasher::LOWEST))->needsRehash($hash));
        self::assertTrue(password_verify(AuthFixtures::PASSWORD, $hash));
    }
}
