<?php

declare(strict_types=1);

namespace Wio\Auth;

/**
 * What a sign-in attempt ended in. Exactly one of the shapes below.
 */
final readonly class SignInResult
{
    public const string SIGNED_IN = 'signed_in';
    public const string INVALID = 'invalid_credentials';
    public const string LIMITED = 'too_many_attempts';
    public const string CHOOSE = 'workspace_choice_required';

    /**
     * @param array{token: string, device_id: string, user: array{id: string, role: string, display_name: ?string}, workspace: array{id: string, name: ?string, plan: string}}|null $signedIn
     * @param list<array{id: string, name: ?string}> $workspaces
     */
    private function __construct(
        public string $kind,
        public ?array $signedIn = null,
        public array $workspaces = [],
        public int $retryAfter = 0,
    ) {}

    /**
     * @param array{token: string, device_id: string, user: array{id: string, role: string, display_name: ?string}, workspace: array{id: string, name: ?string, plan: string}} $signedIn
     */
    public static function signedIn(array $signedIn): self
    {
        return new self(self::SIGNED_IN, signedIn: $signedIn);
    }

    public static function invalid(): self
    {
        return new self(self::INVALID);
    }

    public static function limited(int $retryAfter): self
    {
        return new self(self::LIMITED, retryAfter: $retryAfter);
    }

    /**
     * @param list<array{id: string, name: ?string}> $workspaces
     */
    public static function choose(array $workspaces): self
    {
        return new self(self::CHOOSE, workspaces: $workspaces);
    }
}
