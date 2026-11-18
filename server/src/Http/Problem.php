<?php

declare(strict_types=1);

namespace Wio\Http;

use Psr\Http\Message\ResponseInterface;

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

    public static function notFound(ResponseInterface $response): ResponseInterface
    {
        return self::write($response, 404, 'not_found', 'Not found');
    }
}
