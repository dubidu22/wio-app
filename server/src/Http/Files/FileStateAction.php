<?php

declare(strict_types=1);

namespace Wio\Http\Files;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Files\FileStore;
use Wio\Http\Json;
use Wio\Http\Problem;
use Wio\Sync\Rights;

/**
 * GET /files/{sha256}/state (getFileState): how much of a file this
 * workspace holds. An unknown file answers 0 bytes (D-185).
 */
final class FileStateAction
{
    /**
     * @param \Closure(): FileStore $files
     */
    public function __construct(private readonly \Closure $files) {}

    /**
     * @param array<string, string> $arguments
     */
    public function __invoke(ServerRequestInterface $request, ResponseInterface $response, array $arguments): ResponseInterface
    {
        $caller = AuthContext::of($request);
        if (!Rights::mayUseFiles($caller)) {
            return Problem::forbidden($response);
        }

        return Json::write($response, ($this->files)()->state($caller->workspaceId, FileArguments::sha256($arguments)));
    }
}
