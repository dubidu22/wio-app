<?php

declare(strict_types=1);

namespace Wio;

use PDO;
use Psr\Clock\ClockInterface;
use Wio\Auth\DeviceTokens;
use Wio\Auth\PasswordHasher;
use Wio\Auth\SignIn;
use Wio\Auth\SignInLimiter;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Support\SystemClock;

/**
 * What the routes need, built on first use: /health never opens the
 * database. Tests pass their own connection, clock and hash cost (D-120).
 */
final class Services
{
    private ?Sql $sql = null;

    private ?PasswordHasher $hasher = null;

    /** @var \Closure(string): void */
    public readonly \Closure $log;

    /**
     * @param \Closure(): PDO $connect
     * @param \Closure(): PasswordHasher $makeHasher
     * @param \Closure(string): void $log one line to the server's error log; never a password, token or body
     */
    public function __construct(
        private readonly \Closure $connect,
        public readonly ClockInterface $clock,
        private readonly \Closure $makeHasher,
        ?\Closure $log = null,
    ) {
        $this->log = $log ?? static function (string $line): void {
            error_log($line);
        };
    }

    public static function fromEnvironment(): self
    {
        return new self(
            static fn(): PDO => Connection::fromEnvironment(),
            new SystemClock(),
            static fn(): PasswordHasher => new PasswordHasher(),
        );
    }

    public function sql(): Sql
    {
        return $this->sql ??= new Sql(($this->connect)());
    }

    public function hasher(): PasswordHasher
    {
        return $this->hasher ??= ($this->makeHasher)();
    }

    public function deviceTokens(): DeviceTokens
    {
        return new DeviceTokens($this->sql(), $this->clock);
    }

    public function signIn(): SignIn
    {
        return new SignIn(
            $this->sql(),
            $this->clock,
            $this->hasher(),
            new SignInLimiter($this->sql(), $this->clock),
            $this->deviceTokens(),
            $this->log,
        );
    }
}
