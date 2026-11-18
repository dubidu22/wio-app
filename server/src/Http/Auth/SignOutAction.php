<?php

declare(strict_types=1);

namespace Wio\Http\Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Auth\DeviceTokens;

/**
 * POST /auth/sign-out (signOut): deletes the calling device's token.
 */
final class SignOutAction
{
    /**
     * @param \Closure(): DeviceTokens $tokens
     */
    public function __construct(private readonly \Closure $tokens) {}

    public function __invoke(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $caller = AuthContext::of($request);
        ($this->tokens)()->delete($caller->workspaceId, $caller->userId, $caller->deviceId);

        return $response->withStatus(204);
    }
}
