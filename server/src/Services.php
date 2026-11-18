<?php

declare(strict_types=1);

namespace Wio;

use PDO;
use Psr\Clock\ClockInterface;
use Wio\AppVersion\AppVersion;
use Wio\AppVersion\MinimumAppVersion;
use Wio\Auth\DeviceTokens;
use Wio\Auth\PasswordHasher;
use Wio\Auth\SignIn;
use Wio\Auth\SignInLimiter;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Http\Cors;
use Wio\Support\SystemClock;
use Wio\Sync\Pull;
use Wio\Sync\Push;

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

    /** Apps below it get 426 (D-145); null for no minimum. */
    public readonly ?AppVersion $minimumAppVersion;

    /** Origins allowed to read answers in a browser (D-164). */
    public readonly Cors $cors;

    /**
     * @param \Closure(): PDO $connect
     * @param \Closure(): PasswordHasher $makeHasher
     * @param \Closure(string): void $log one line to the server's error log; never a password, token or body
     * @param ?string $minimumAppVersion `major.minor.patch`; tests pass their own
     * @param string $corsOrigins the `WIO_CORS_ORIGINS` list, comma-separated
     */
    public function __construct(
        private readonly \Closure $connect,
        public readonly ClockInterface $clock,
        private readonly \Closure $makeHasher,
        ?\Closure $log = null,
        ?string $minimumAppVersion = MinimumAppVersion::VALUE,
        string $corsOrigins = '',
    ) {
        $this->log = $log ?? static function (string $line): void {
            error_log($line);
        };
        $this->minimumAppVersion = $minimumAppVersion === null ? null : AppVersion::minimum($minimumAppVersion);
        $this->cors = Cors::fromConfig($corsOrigins);
    }

    public static function fromEnvironment(): self
    {
        return new self(
            static fn(): PDO => Connection::fromEnvironment(),
            new SystemClock(),
            static fn(): PasswordHasher => new PasswordHasher(),
            corsOrigins: (string) getenv('WIO_CORS_ORIGINS'),
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

    public function push(): Push
    {
        return new Push($this->sql(), $this->clock);
    }

    public function pull(): Pull
    {
        return new Pull($this->sql());
    }
}
