<?php

declare(strict_types=1);

namespace Wio\Auth;

use Psr\Http\Message\ServerRequestInterface;

/**
 * Reads the bearer token. PHP behind CGI or FPM on shared hosting often drops
 * the Authorization header, so public/.htaccess passes it on and the server
 * parameters are read too (D-112).
 */
final class BearerToken
{
    private const array SERVER_PARAMETERS = ['HTTP_AUTHORIZATION', 'REDIRECT_HTTP_AUTHORIZATION'];

    private function __construct() {}

    public static function from(ServerRequestInterface $request): ?string
    {
        $header = $request->getHeaderLine('Authorization');
        if ($header === '') {
            $server = $request->getServerParams();
            foreach (self::SERVER_PARAMETERS as $name) {
                if (\is_string($server[$name] ?? null) && $server[$name] !== '') {
                    $header = $server[$name];
                    break;
                }
            }
        }

        if (preg_match('/^Bearer\s+(\S+)\s*$/i', $header, $match) !== 1) {
            return null;
        }

        return $match[1];
    }
}
