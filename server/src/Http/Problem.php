<?php

declare(strict_types=1);

namespace Wio\Http;

use Psr\Http\Message\ResponseInterface;
use Wio\AppVersion\AppVersion;

/**
 * RFC 9457 problem details with the machine `code` the app classifies by
 * (D-98, D-116).
 */
final class Problem
{
    private function __construct() {}

    /**
     * @param array<string, mixed> $extra
     */
    public static function write(
        ResponseInterface $response,
        int $status,
        string $code,
        string $title,
        ?string $detail = null,
        array $extra = [],
    ): ResponseInterface {
        $body = ['type' => 'about:blank', 'title' => $title, 'status' => $status, 'code' => $code];
        if ($detail !== null) {
            $body['detail'] = $detail;
        }

        return Json::write($response, $body + $extra, $status, 'application/problem+json');
    }

    public static function tokenInvalid(ResponseInterface $response): ResponseInterface
    {
        return self::write($response, 401, 'token_invalid', 'Sign in again')
            ->withHeader('WWW-Authenticate', 'Bearer');
    }

    /**
     * The caller's role may not use the operation (D-206).
     */
    public static function forbidden(ResponseInterface $response): ResponseInterface
    {
        return self::write($response, 403, 'forbidden', 'Not allowed for this role');
    }

    public static function notFound(ResponseInterface $response): ResponseInterface
    {
        return self::write($response, 404, 'not_found', 'Not found');
    }

    /**
     * The app is older than the server's minimum (D-144): update the app;
     * its local data stays.
     */
    public static function upgradeRequired(ResponseInterface $response, AppVersion $minimum): ResponseInterface
    {
        return self::write(
            $response,
            426,
            'upgrade_required',
            'Update the app',
            'This app version is no longer supported. Update the app; data on the device is kept.',
            ['minimum_app_version' => (string) $minimum],
        );
    }
}
