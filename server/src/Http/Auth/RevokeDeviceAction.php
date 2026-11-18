<?php

declare(strict_types=1);

namespace Wio\Http\Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Auth\DeviceTokens;
use Wio\Http\Problem;

/**
 * DELETE /auth/devices/{device_id} (revokeDevice): signs out one of the
 * caller's own devices. Any other id is 404, so ids are not confirmed.
 */
final class RevokeDeviceAction
{
    /**
     * @param \Closure(): DeviceTokens $tokens
     */
    public function __construct(private readonly \Closure $tokens) {}

    /**
     * @param array<string, string> $arguments
     */
    public function __invoke(ServerRequestInterface $request, ResponseInterface $response, array $arguments): ResponseInterface
    {
        $caller = AuthContext::of($request);
        $deviceId = strtolower($arguments['device_id'] ?? '');
        if (!($this->tokens)()->delete($caller->workspaceId, $caller->userId, $deviceId)) {
            return Problem::notFound($response);
        }

        return $response->withStatus(204);
    }
}
