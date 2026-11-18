<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Auth;

use PHPUnit\Framework\TestCase;
use Wio\Auth\PasswordHasher;

/**
 * Argon2id with PHP's defaults (D-108), plan 005 test T8.
 */
final class PasswordHasherTest extends TestCase
{
    public function testThisPhpHasArgon2id(): void
    {
        self::assertContains('argon2id', password_algos(), 'ext-sodium or libargon2 is required (D-108)');
    }

    public function testProductionUsesPhpsDefaults(): void
    {
        self::assertSame(['memory_cost' => 65536, 'time_cost' => 4, 'threads' => 1], PasswordHasher::PRODUCTION);
    }

    public function testItHashesWithArgon2idAndVerifies(): void
    {
        $hasher = new PasswordHasher(PasswordHasher::LOWEST);
        $hash = $hasher->hash('richtig-geheim');

        self::assertStringStartsWith('$argon2id$v=19$m=8,t=1,p=1$', $hash);
        self::assertTrue($hasher->verify('richtig-geheim', $hash));
        self::assertFalse($hasher->verify('falsch', $hash));
        self::assertFalse($hasher->needsRehash($hash));
    }

    public function testACheaperHashNeedsARehash(): void
    {
        $cheap = (new PasswordHasher(PasswordHasher::LOWEST))->hash('richtig-geheim');
        $bcrypt = password_hash('richtig-geheim', PASSWORD_BCRYPT);

        self::assertTrue((new PasswordHasher())->needsRehash($cheap));
        self::assertTrue((new PasswordHasher(PasswordHasher::LOWEST))->needsRehash($bcrypt));
    }
}
