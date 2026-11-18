<?php

declare(strict_types=1);

namespace Wio\Auth;

use RuntimeException;

/**
 * Argon2id password hashes (D-108). Production uses PHP's defaults; tests pass
 * the lowest cost PHP accepts (D-120). A hash made with other options is
 * upgraded at the next successful sign-in.
 */
final class PasswordHasher implements PasswordHashing
{
    /** PHP's Argon2id defaults: 64 MiB, 4 passes, 1 thread. */
    public const array PRODUCTION = [
        'memory_cost' => PASSWORD_ARGON2_DEFAULT_MEMORY_COST,
        'time_cost' => PASSWORD_ARGON2_DEFAULT_TIME_COST,
        'threads' => PASSWORD_ARGON2_DEFAULT_THREADS,
    ];

    /** For tests only. */
    public const array LOWEST = ['memory_cost' => 8, 'time_cost' => 1, 'threads' => 1];

    /**
     * @param array{memory_cost: int, time_cost: int, threads: int} $options
     */
    public function __construct(private readonly array $options = self::PRODUCTION)
    {
        if (!\defined('PASSWORD_ARGON2ID')) {
            throw new RuntimeException('This PHP has no Argon2id (D-108); install ext-sodium or libargon2.');
        }
    }

    public function hash(#[\SensitiveParameter] string $password): string
    {
        return password_hash($password, PASSWORD_ARGON2ID, $this->options);
    }

    public function verify(#[\SensitiveParameter] string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }

    public function needsRehash(string $hash): bool
    {
        return password_needs_rehash($hash, PASSWORD_ARGON2ID, $this->options);
    }

    public function spendOneCheck(#[\SensitiveParameter] string $password): void
    {
        $this->hash($password);
    }
}
