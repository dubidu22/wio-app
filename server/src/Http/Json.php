<?php

declare(strict_types=1);

namespace Wio\Http;

use Psr\Http\Message\ResponseInterface;

/**
 * Writes JSON bodies with the right content type.
 */
final class Json
{
    private function __construct() {}

    /**
     * @param array<string, mixed> $body
     */
    public static function write(ResponseInterface $response, array $body, int $status = 200, string $type = 'application/json'): ResponseInterface
    {
        $response->getBody()->write(json_encode($body, JSON_THROW_ON_ERROR | JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE));

        return $response->withStatus($status)->withHeader('Content-Type', $type);
    }
}
