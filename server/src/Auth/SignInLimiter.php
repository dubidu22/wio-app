<?php

declare(strict_types=1);

namespace Wio\Auth;

use DateInterval;
use Psr\Clock\ClockInterface;
use Wio\Database\Sql;
use Wio\Schema\NameKey;
use Wio\Support\Time;

/**
 * Limits failed sign-ins in MariaDB, the only state shared by all PHP workers
 * on the hosting (D-113). Rows hold SHA-256 hashes of the e-mail key and of
 * the IP key (D-137) and are deleted after a day.
 *
 * An attempt reserves its row before the password check and counts the
 * window including that row (reserve, then exceeded). Parallel attempts each
 * see the rows of the others, so together they never get more password
 * checks than the limit allows.
 */
final class SignInLimiter
{
    public const int PER_EMAIL = 10;
    public const int PER_IP = 30;
    public const string WINDOW = 'PT15M';
    public const string KEEP = 'PT24H';

    public function __construct(private readonly Sql $sql, private readonly ClockInterface $clock) {}

    public static function emailHash(string $email): string
    {
        return hash('sha256', NameKey::of($email));
    }

    public static function ipHash(string $ip): string
    {
        return hash('sha256', self::ipKey($ip));
    }

    /**
     * The address the per-IP limit counts (D-137): an IPv6 client by its /64
     * prefix, because one client usually holds a whole /64; an IPv4-mapped
     * IPv6 address as its IPv4 address; IPv4 unchanged. Anything that is not
     * an IP address is counted as given.
     */
    public static function ipKey(string $ip): string
    {
        if (filter_var($ip, FILTER_VALIDATE_IP) === false) {
            return $ip;
        }
        $packed = inet_pton($ip);
        if ($packed === false || \strlen($packed) === 4) {
            return $ip;
        }
        if (str_starts_with($packed, str_repeat("\0", 10) . "\xff\xff")) {
            return (string) inet_ntop(substr($packed, 12));
        }

        return inet_ntop(substr($packed, 0, 8) . str_repeat("\0", 8)) . '/64';
    }

    /**
     * Records this attempt as a failure before its password is checked and
     * returns the row's id. The caller keeps it on a wrong password and
     * releases it otherwise.
     */
    public function reserve(string $emailHash, string $ipHash): int
    {
        $this->sql->run(
            'INSERT INTO sign_in_failures (email_hash, ip_hash, failed_at) VALUES (?, ?, ?)',
            [$emailHash, $ipHash, Time::toDatabase($this->clock->now())],
        );

        return (int) $this->sql->pdo->lastInsertId();
    }

    /**
     * Whether the window, including the caller's own reserved row, holds more
     * failures than a limit allows.
     */
    public function exceeded(string $emailHash, string $ipHash): bool
    {
        $since = Time::toDatabase($this->clock->now()->sub(new DateInterval(self::WINDOW)));
        foreach ([['email_hash', $emailHash, self::PER_EMAIL], ['ip_hash', $ipHash, self::PER_IP]] as [$column, $hash, $limit]) {
            $count = $this->sql->run("SELECT COUNT(*) FROM sign_in_failures WHERE {$column} = ? AND failed_at > ?", [$hash, $since])->fetchColumn();
            if (!is_numeric($count) || (int) $count > $limit) {
                return true;
            }
        }

        return false;
    }

    public function release(int $id): void
    {
        $this->sql->run('DELETE FROM sign_in_failures WHERE id = ?', [$id]);
    }

    /**
     * Seconds to wait before the next attempt, or null when it may go ahead.
     */
    public function retryAfter(string $emailHash, string $ipHash): ?int
    {
        $wait = null;
        foreach ([['email_hash', $emailHash, self::PER_EMAIL], ['ip_hash', $ipHash, self::PER_IP]] as [$column, $hash, $limit]) {
            $seconds = $this->waitFor($column, $hash, $limit);
            if ($seconds !== null) {
                $wait = max($wait ?? 0, $seconds);
            }
        }

        return $wait;
    }

    public function clear(string $emailHash): void
    {
        $this->sql->run('DELETE FROM sign_in_failures WHERE email_hash = ?', [$emailHash]);
    }

    /**
     * Deletes failures older than a day; runs on every sign-in, because the
     * hosting has no background jobs.
     */
    public function purge(): void
    {
        $this->sql->run(
            'DELETE FROM sign_in_failures WHERE failed_at < ?',
            [Time::toDatabase($this->clock->now()->sub(new DateInterval(self::KEEP)))],
        );
    }

    /**
     * With $limit or more failures in the window, the wait until enough of
     * them have left it for one more attempt.
     */
    private function waitFor(string $column, string $hash, int $limit): ?int
    {
        $now = $this->clock->now();
        $window = new DateInterval(self::WINDOW);
        $times = $this->sql->rows(
            "SELECT failed_at FROM sign_in_failures WHERE {$column} = ? AND failed_at > ? ORDER BY failed_at DESC",
            [$hash, Time::toDatabase($now->sub($window))],
        );
        if (\count($times) < $limit) {
            return null;
        }
        // The newest $limit failures block; the oldest of them frees a slot.
        $freesSlot = Time::fromDatabase(Sql::text($times[$limit - 1]['failed_at']))->add($window);

        return max(1, Time::secondsUntil($now, $freesSlot));
    }
}
