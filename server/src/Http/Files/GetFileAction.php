<?php

declare(strict_types=1);

namespace Wio\Http\Files;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Files\ByteRange;
use Wio\Files\FileAccess;
use Wio\Files\FileRangeStream;
use Wio\Files\FileStore;
use Wio\Http\Problem;
use Wio\Sync\Rights;

/**
 * GET /files/{sha256} (getFile, plan 055). Checks in the order of D-232:
 * role (helpers 403, D-206), hash pattern (400), record scope (one 404 for
 * every hash the caller may not read, D-224), then If-None-Match (304,
 * D-229) and Range (206/416, D-230). The body streams from the open file
 * (D-231); every answer with bytes carries the safety headers of D-228.
 */
final class GetFileAction
{
    /**
     * @param \Closure(): FileAccess $access
     * @param \Closure(): FileStore $files
     */
    public function __construct(
        private readonly \Closure $access,
        private readonly \Closure $files,
    ) {}

    /**
     * @param array<string, string> $arguments
     */
    public function __invoke(ServerRequestInterface $request, ResponseInterface $response, array $arguments): ResponseInterface
    {
        $caller = AuthContext::of($request);
        if (!Rights::mayUseFiles($caller)) {
            return Problem::forbidden($response);
        }
        $sha256 = FileArguments::sha256($arguments);
        $type = ($this->access)()->contentType($caller, $sha256);
        $file = $type === null ? null : ($this->files)()->open($caller->workspaceId, $sha256);
        if ($type === null || $file === null) {
            return Problem::notFound($response);
        }
        [$handle, $size] = $file;
        $etag = '"' . $sha256 . '"';
        $response = $response
            ->withHeader('ETag', $etag)
            ->withHeader('Cache-Control', 'private, no-cache');

        if (self::matchesAny($request->getHeaderLine('If-None-Match'), $etag)) {
            fclose($handle);

            return $response->withStatus(304);
        }

        $range = null;
        if ($request->hasHeader('Range') && (!$request->hasHeader('If-Range') || trim($request->getHeaderLine('If-Range')) === $etag)) {
            $range = ByteRange::parse($request->getHeaderLine('Range'), $size);
        }
        if ($range === false) {
            fclose($handle);

            return Problem::write(
                $response,
                416,
                'range_not_satisfiable',
                'Range not satisfiable',
                "The file has {$size} bytes.",
            )->withHeader('Content-Range', "bytes */{$size}");
        }

        $response = $response
            ->withHeader('Accept-Ranges', 'bytes')
            ->withHeader('Content-Type', $type)
            ->withHeader('X-Content-Type-Options', 'nosniff')
            ->withHeader('Content-Security-Policy', "default-src 'none'; sandbox")
            ->withHeader('Content-Disposition', 'attachment; filename="' . $sha256 . '"');
        if ($range === null) {
            return $response
                ->withHeader('Content-Length', (string) $size)
                ->withBody(new FileRangeStream($handle, 0, $size));
        }

        return $response
            ->withStatus(206)
            ->withHeader('Content-Length', (string) $range->length())
            ->withHeader('Content-Range', "bytes {$range->first}-{$range->last}/{$size}")
            ->withBody(new FileRangeStream($handle, $range->first, $range->length()));
    }

    /**
     * If-None-Match uses the weak comparison (RFC 9110 13.1.2): `*`, or any
     * listed tag equal to ours with or without `W/`.
     */
    private static function matchesAny(string $header, string $etag): bool
    {
        if (trim($header) === '') {
            return false;
        }
        foreach (explode(',', $header) as $tag) {
            $tag = trim($tag);
            if ($tag === '*' || $tag === $etag || $tag === 'W/' . $etag) {
                return true;
            }
        }

        return false;
    }
}
