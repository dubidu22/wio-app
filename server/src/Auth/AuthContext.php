<?php

declare(strict_types=1);

namespace Wio\Auth;

use Psr\Http\Message\ServerRequestInterface;
use RuntimeException;

/**
 * Who is calling, taken from the device token (D-112). Every query takes the
 * workspace and role from here, never from the request.
 */
final readonly class AuthContext
{
    public const string ATTRIBUTE = self::class;

    public function __construct(
        public string $workspaceId,
        public string $userId,
        public string $role,
        public ?string $customerId,
        public string $deviceId,
    ) {}

    public static function of(ServerRequestInterface $request): self
    {
        $context = $request->getAttribute(self::ATTRIBUTE);
        if (!$context instanceof self) {
            throw new RuntimeException('The route has no auth middleware.');
        }

        return $context;
    }
}
