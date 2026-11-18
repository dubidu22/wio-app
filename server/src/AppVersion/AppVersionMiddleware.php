<?php

declare(strict_types=1);

namespace Wio\AppVersion;

use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\MiddlewareInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Wio\Http\Problem;

/**
 * Checks `Wio-App-Version` on every operation, before the auth middleware
 * and before any password check (D-142, D-143). No header: the request goes
 * on (monitors and smoke tests send none). A malformed header: 400
 * `invalid_request`. Below the minimum: 426 `upgrade_required` (D-144).
 * Never touches the database.
 */
final readonly class AppVersionMiddleware implements MiddlewareInterface
{
    public function __construct(
        private ?AppVersion $minimum,
        private ResponseFactoryInterface $responses,
    ) {}

    public function process(ServerRequestInterface $request, RequestHandlerInterface $handler): ResponseInterface
    {
        if (!$request->hasHeader(AppVersion::HEADER)) {
            return $handler->handle($request);
        }

        $version = AppVersion::parse($request->getHeaderLine(AppVersion::HEADER));
        if ($version === null) {
            // Never repeat the submitted value (D-116).
            return Problem::write(
                $this->responses->createResponse(),
                400,
                'invalid_request',
                'Invalid request',
                'The Wio-App-Version header must be major.minor.patch with an optional +build.',
            );
        }
        if ($this->minimum !== null && $version->isBelow($this->minimum)) {
            return Problem::upgradeRequired($this->responses->createResponse(), $this->minimum);
        }

        return $handler->handle($request);
    }
}
