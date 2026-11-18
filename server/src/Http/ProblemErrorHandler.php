<?php

declare(strict_types=1);

namespace Wio\Http;

use Psr\Http\Message\ResponseFactoryInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Slim\Exception\HttpMethodNotAllowedException;
use Slim\Exception\HttpNotFoundException;
use Throwable;

/**
 * Every error as problem+json with a `code` (D-98, D-116). An unexpected error
 * is logged without the request body, headers or database values, so a
 * password, token or e-mail never reaches a log, and answered without details.
 */
final class ProblemErrorHandler
{
    /**
     * @param \Closure(string): void $log
     */
    public function __construct(
        private readonly ResponseFactoryInterface $responses,
        private readonly \Closure $log,
    ) {}

    public function __invoke(
        ServerRequestInterface $request,
        Throwable $error,
        bool $displayErrorDetails,
        bool $logErrors,
        bool $logErrorDetails,
    ): ResponseInterface {
        $response = $this->responses->createResponse();

        if ($error instanceof HttpNotFoundException) {
            return Problem::notFound($response);
        }
        if ($error instanceof HttpMethodNotAllowedException) {
            return Problem::write($response, 405, 'method_not_allowed', 'Method not allowed')
                ->withHeader('Allow', implode(', ', $error->getAllowedMethods()));
        }
        if ($error instanceof InvalidRequest) {
            return Problem::write($response, 400, 'invalid_request', 'Invalid request', $error->getMessage());
        }

        ($this->log)(sprintf(
            'wio: %s in %s:%d on %s %s: %s',
            $error::class,
            $error->getFile(),
            $error->getLine(),
            $request->getMethod(),
            $request->getUri()->getPath(),
            // A database message can quote stored values (an e-mail in a
            // duplicate key), so only its SQLSTATE is logged.
            $error instanceof \PDOException ? 'SQLSTATE ' . (string) $error->getCode() : $error->getMessage(),
        ));

        return Problem::write($response, 500, 'internal', 'Server error');
    }
}
