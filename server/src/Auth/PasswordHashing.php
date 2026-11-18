<?php

declare(strict_types=1);

namespace Wio\Auth;

/**
 * Password hashing as sign-in uses it; PasswordHasher is the only production
 * implementation (D-108). Tests count calls through it.
 */
interface PasswordHashing
{
    public function hash(#[\SensitiveParameter] string $password): string;

    public function verify(#[\SensitiveParameter] string $password, string $hash): bool;

    public function needsRehash(string $hash): bool;

    /**
     * Costs the same as one verify, for an e-mail that has no password, so
     * the answer time does not tell which e-mails exist (D-113).
     */
    public function spendOneCheck(#[\SensitiveParameter] string $password): void;
}
