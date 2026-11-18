<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Auth;

use Psr\Clock\ClockInterface;
use Wio\Auth\DeviceTokens;
use Wio\Auth\PasswordHasher;
use Wio\Auth\PasswordHashing;
use Wio\Auth\SignIn;
use Wio\Auth\SignInLimiter;
use Wio\Auth\SignInResult;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;
use Wio\Tests\Support\AuthFixtures;
use Wio\Tests\Support\FakePasswordHasher;

/**
 * Sign-in limits in MariaDB (D-113, D-137), plan 005 test T4, and the dummy
 * check for unknown e-mails (T3).
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
        $hasher = new FakePasswordHasher();
        $signIn = self::signInWith($this->sql, $this->clock, $hasher);

        $signIn->attempt('niemand@example.org', 'falsch', 'Pixel Test', null, self::IP);
        self::assertSame(['spend'], $hasher->calls);

        $hasher->calls = [];
        $signIn->attempt('inhaber@example.org', 'falsch', 'Pixel Test', null, self::IP);
        self::assertSame(['verify'], $hasher->calls);
    }

    public function testAParallelAttemptCountsTheOneInFlight(): void
    {
        $this->fixtures->user($this->fixtures->workspace());
        $limiter = new SignInLimiter($this->sql, $this->clock);
        $emailHash = SignInLimiter::emailHash('inhaber@example.org');
        for ($i = 0; $i < SignInLimiter::PER_EMAIL - 1; ++$i) {
            $limiter->reserve($emailHash, SignInLimiter::ipHash("192.0.2.{$i}"));
        }

        // A second worker with its own connection starts its attempt while
        // the first one's password is being checked, one below the limit.
        $other = new Sql(Connection::fromEnvironment());
        $second = self::signInWith($other, $this->clock, new PasswordHasher(PasswordHasher::LOWEST));
        $inner = null;
        $first = self::signInWith($this->sql, $this->clock, new FakePasswordHasher(static function () use ($second, &$inner): void {
            $inner = $second->attempt('inhaber@example.org', AuthFixtures::PASSWORD, 'Zweites Gerät', null, '198.51.100.7');
        }));

        $outer = $first->attempt('inhaber@example.org', 'falsch', 'Pixel Test', null, self::IP);

        self::assertSame(SignInResult::INVALID, $outer->kind);
        self::assertInstanceOf(SignInResult::class, $inner);
        self::assertSame(SignInResult::LIMITED, $inner->kind, 'the attempt in flight already counts, so the parallel one is not checked');
        self::assertSame(SignInLimiter::PER_EMAIL, $this->fixtures->count('sign_in_failures'), 'the limited attempt released its row');
        self::assertSame(0, $this->fixtures->count('device_tokens'));
    }

    public function testOneIpv6SlashSixtyFourSharesTheAddressLimit(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        for ($i = 0; $i < SignInLimiter::PER_IP; ++$i) {
            $ip = sprintf('2001:db8:1:2:%x::1', $i);
            self::assertProblem($this->signIn(self::credentials("unbekannt{$i}@example.org"), $ip), 401, 'invalid_credentials');
        }

        self::assertProblem($this->signIn(self::credentials(), '2001:db8:1:2:ffff:ffff:ffff:ffff'), 429, 'too_many_attempts');
        self::assertSame(
            [['ip_hash' => hash('sha256', '2001:db8:1:2::/64')]],
            $this->sql->rows('SELECT DISTINCT ip_hash FROM sign_in_failures'),
            'only the hash of the /64 is stored (D-137)',
        );
        self::assertSame(200, $this->signIn(self::credentials(), '2001:db8:1:3::1')->getStatusCode(), 'another /64 is not limited');
    }

    public function testAMappedIpv4AddressCountsAsThatIpv4Address(): void
    {
        $this->fixtures->user($this->fixtures->workspace());

        for ($i = 0; $i < SignInLimiter::PER_IP; ++$i) {
            $ip = $i % 2 === 0 ? '::ffff:192.0.2.77' : '192.0.2.77';
            self::assertProblem($this->signIn(self::credentials("unbekannt{$i}@example.org"), $ip), 401, 'invalid_credentials');
        }

        self::assertProblem($this->signIn(self::credentials(), '192.0.2.77'), 429, 'too_many_attempts');
        self::assertProblem($this->signIn(self::credentials(), '::ffff:192.0.2.77'), 429, 'too_many_attempts');
    }

    private static function signInWith(Sql $sql, ClockInterface $clock, PasswordHashing $hasher): SignIn
    {
        return new SignIn($sql, $clock, $hasher, new SignInLimiter($sql, $clock), new DeviceTokens($sql, $clock), static function (string $line): void {});
    }
}
