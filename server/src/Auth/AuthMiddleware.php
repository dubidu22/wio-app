<?php

declare(strict_types=1);

namespace Wio\Auth;

use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Wio\Http\Problem;

/**
 * Resolves the bearer token to an AuthContext on every operation except the
 * public ones (D-112). Any missing or invalid token gets the same
 * 401 `token_invalid`.
 */
final class AuthMiddleware implements MiddlewareInterface
{
    /**
     * @param \Closure(): DeviceTokens $tokens
     */
    public function __construct(
        private readonly \Closure $tokens,
        private readonly ResponseFactoryInterface $responses,
    ) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        $token = BearerToken::from($request);
        $context = $token === null ? null : ($this->tokens)()->resolve($token);
        if ($context === null) {
            return Problem::tokenInvalid($this->responses->createResponse());
        }

        return $handler->handle($request->withAttribute(AuthContext::ATTRIBUTE, $context));
    }
}
