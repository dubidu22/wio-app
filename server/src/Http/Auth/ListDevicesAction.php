<?php

declare(strict_types=1);

namespace Wio\Http\Auth;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Auth\DeviceTokens;
use Wio\Http\Json;
use Wio\Support\Time;

/**
 * GET /auth/devices (listDevices): the caller's own signed-in devices.
 */
final class ListDevicesAction
{
    /**
     * @param \Closure(): DeviceTokens $tokens
     */
    public function __construct(private readonly \Closure $tokens) {}

    public function __invoke(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $caller = AuthContext::of($request);
        $devices = [];
        foreach (($this->tokens)()->listFor($caller->workspaceId, $caller->userId) as $device) {
            $devices[] = [
                'id' => $device['id'],
                'device_name' => $device['device_name'],
                'created_at' => Time::toJson($device['created_at']),
                'last_used_at' => Time::toJson($device['last_used_at']),
                'current' => $device['id'] === $caller->deviceId,
            ];
        }

        return Json::write($response, ['devices' => $devices]);
    }
}
