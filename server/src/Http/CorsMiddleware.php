<?php

declare(strict_types=1);

namespace Wio\Http;

use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;

/**
 * CORS for a web app on its own origin (D-163 to D-170). The outermost
 * middleware: it answers preflights itself, before routing, the app-version
 * check and auth (D-165), and it adds the headers to every answer for a
 * listed origin, problem answers included (D-166, D-168). Origins not on the
 * list get no CORS headers. Never `Allow-Credentials` (D-167).
 */
final readonly class CorsMiddleware implements MiddlewareInterface
{
    /**
     * @param \Closure(string): void $log
     */
    public function __construct(
        private Cors $cors,
        private ResponseFactoryInterface $responses,
        private \Closure $log,
    ) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        if (!$request->hasHeader('Origin')) {
            return $handler->handle($request);
        }
        $origin = $request->getHeaderLine('Origin');
        $allowed = $this->cors->allows($origin);
        if (!$allowed && \in_array(strtolower($origin), $this->cors->dropped, true)) {
            ($this->log)('wio cors: a request came from an origin that WIO_CORS_ORIGINS lists in a form that is not allowed; it gets no CORS headers.');
        }

        if ($request->getMethod() === 'OPTIONS' && $request->hasHeader('Access-Control-Request-Method')) {
            $response = $this->responses->createResponse(204)->withHeader('Vary', 'Origin');
            if (!$allowed) {
                return $response;
            }

            return $response
                ->withHeader('Access-Control-Allow-Origin', strtolower($origin))
                ->withHeader('Access-Control-Allow-Methods', implode(', ', Cors::METHODS))
                ->withHeader('Access-Control-Allow-Headers', implode(', ', Cors::HEADERS))
                ->withHeader('Access-Control-Max-Age', (string) Cors::MAX_AGE);
        }

        $response = $handler->handle($request)->withAddedHeader('Vary', 'Origin');
        if (!$allowed) {
            return $response;
        }

        return $response
            ->withHeader('Access-Control-Allow-Origin', strtolower($origin))
            ->withHeader('Access-Control-Expose-Headers', implode(', ', Cors::EXPOSE));
    }
}
