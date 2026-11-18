<?php

declare(strict_types=1);

namespace Wio\Tests\Support;

use Wio\Auth\PasswordHashing;

/**
 * A hasher that records its calls and never matches. A test can run code
 * inside verify(), to interleave a second attempt with the first.
 */
final class FakePasswordHasher implements PasswordHashing
{
    /** @var list<string> */
    public array $calls = [];

    /**
     * @param (\Closure(): void)|null $duringVerify
     */
    public function __construct(private readonly ?\Closure $duringVerify = null) {}

    public function hash(#[\SensitiveParameter] string $password): string
    {
        $this->calls[] = 'hash';

        return 'x';
    }

    public function verify(#[\SensitiveParameter] string $password, string $hash): bool
    {
        $this->calls[] = 'verify';
        if ($this->duringVerify !== null) {
            ($this->duringVerify)();
        }

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
}
