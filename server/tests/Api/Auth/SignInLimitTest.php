<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Auth;

use Wio\Auth\DeviceTokens;
use Wio\Auth\PasswordHashing;
use Wio\Auth\SignIn;
use Wio\Auth\SignInLimiter;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;

/**
 * Sign-in limits in MariaDB (D-113), plan 005 test T4, and the dummy check
 * for unknown e-mails (T3).
 */
#[Operation('signIn')]
final class SignInLimitTest extends DatabaseTestCase
{
    public function testTheEleventhFailureForOneEMailWaits(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        for ($i = 0; $i < SignInLimiter::PER_EMAIL; ++$i) {
            self::assertProblem($this->signIn(self::credentials(password: 'falsch'), "192.0.2.{$i}"), 401, 'invalid_credentials');
            $this->clock->advance('PT10S');
        }

        // Even the right password waits: a limited request is never checked.
        $limited = $this->signIn(self::credentials(), '198.51.100.7');
        self::assertProblem($limited, 429, 'too_many_attempts');
        // The first failure was 100 s ago and leaves the 15-minute window in 800 s.
        self::assertSame('800', $limited->getHeaderLine('Retry-After'));
        self::assertSame(SignInLimiter::PER_EMAIL, $this->fixtures->count('sign_in_failures'), 'a limited request is not recorded');

        $this->clock->advance('PT799S');
        self::assertProblem($this->signIn(self::credentials()), 429, 'too_many_attempts');
        $this->clock->advance('PT1S');
        self::assertSame(200, $this->signIn(self::credentials())->getStatusCode());
        self::assertSame(0, $this->fixtures->count('sign_in_failures'), 'success clears the e-mail key');
    }

    public function testThirtyFailuresFromOneAddressWaitForEveryEMail(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        for ($i = 0; $i < SignInLimiter::PER_IP; ++$i) {
            self::assertProblem($this->signIn(self::credentials("unbekannt{$i}@example.org")), 401, 'invalid_credentials');
        }

        $limited = $this->signIn(self::credentials());
        self::assertProblem($limited, 429, 'too_many_attempts');
        self::assertSame('900', $limited->getHeaderLine('Retry-After'));
        self::assertSame(200, $this->signIn(self::credentials(), '198.51.100.7')->getStatusCode(), 'another address is not limited');
    }

    public function testFailuresAreKeptOneDayAsHashesOnly(): void
    {
        $this->signIn(self::credentials('Niemand@Example.org'));

        $row = $this->sql->row('SELECT email_hash, ip_hash FROM sign_in_failures');
        self::assertSame(['email_hash' => hash('sha256', 'niemand@example.org'), 'ip_hash' => hash('sha256', self::IP)], $row);

        $this->clock->advance('PT24H');
        $this->clock->advance('PT1S');
        $this->signIn(self::credentials('jemand@example.org'));
        self::assertSame(
            [['email_hash' => hash('sha256', 'jemand@example.org')]],
            $this->sql->rows('SELECT email_hash FROM sign_in_failures'),
            'rows older than a day are deleted at the next sign-in',
        );
    }

    public function testAnUnknownEMailCostsOneCheckToo(): void
    {
        $this->fixtures->user($this->fixtures->workspace());
        $hasher = new class implements PasswordHashing {
            /** @var list<string> */
            public array $calls = [];

            public function hash(#[\SensitiveParameter] string $password): string
            {
                $this->calls[] = 'hash';

                return 'x';
            }

            public function verify(#[\SensitiveParameter] string $password, string $hash): bool
            {
                $this->calls[] = 'verify';

                return false;
            }

            public function needsRehash(string $hash): bool
            {
                return false;
            }

            public function spendOneCheck(#[\SensitiveParameter] string $password): void
            {
                $this->calls[] = 'spend';
            }
        };
        $signIn = new SignIn($this->sql, $this->clock, $hasher, new SignInLimiter($this->sql, $this->clock), new DeviceTokens($this->sql, $this->clock), static function (string $line): void {});

        $signIn->attempt('niemand@example.org', 'falsch', 'Pixel Test', null, self::IP);
        self::assertSame(['spend'], $hasher->calls);

        $hasher->calls = [];
        $signIn->attempt('inhaber@example.org', 'falsch', 'Pixel Test', null, self::IP);
        self::assertSame(['verify'], $hasher->calls);
    }
}
