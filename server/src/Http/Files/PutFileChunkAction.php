<?php

declare(strict_types=1);

namespace Wio\Http\Files;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Files\ContentRange;
use Wio\Files\FileStore;
use Wio\Files\HashMismatch;
use Wio\Files\OffsetMismatch;
use Wio\Http\InvalidRequest;
use Wio\Http\Json;
use Wio\Http\Problem;
use Wio\Sync\Rights;

/**
 * PUT /files/{sha256} (putFileChunk, D-186): one chunk of at most 4 MiB of a
 * file of at most 100 MiB, in order. 202 while more is needed, 200 once the
 * file is complete and matches its hash.
 */
final class PutFileChunkAction
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
        $sha256 = FileArguments::sha256($arguments);
        $range = ContentRange::parse($request->getHeaderLine('Content-Range'));
        if ($range->length() > FileStore::MAX_CHUNK_BYTES || $range->total > FileStore::MAX_FILE_BYTES) {
            return self::tooLarge($response);
        }
        $bytes = self::body($request);
        if (\strlen($bytes) > FileStore::MAX_CHUNK_BYTES) {
            return self::tooLarge($response);
        }
        if (\strlen($bytes) !== $range->length()) {
            throw new InvalidRequest('The body length differs from the Content-Range.');
        }

        try {
            $state = ($this->files)()->put($caller->workspaceId, $sha256, $range, $bytes);
        } catch (OffsetMismatch $e) {
            return Problem::write(
                $response,
                409,
                'offset_mismatch',
                'Resume the upload',
                'The chunk does not start at the received size; send from received_bytes.',
                ['received_bytes' => $e->receivedBytes],
            );
        } catch (HashMismatch) {
            return Problem::write(
                $response,
                422,
                'hash_mismatch',
                'The file does not match its hash',
                'The partial file is gone; upload the file again from 0.',
            );
        }

        return Json::write($response, $state, $state['complete'] ? 200 : 202);
    }

    /**
     * The body, read no further than one byte past the chunk limit.
     */
    private static function body(ServerRequestInterface $request): string
    {
        $stream = $request->getBody();
        if ($stream->isSeekable()) {
            $stream->rewind(); // A middleware may have read it already.
        }
        $bytes = '';
        while (!$stream->eof() && \strlen($bytes) <= FileStore::MAX_CHUNK_BYTES) {
            $read = $stream->read(FileStore::MAX_CHUNK_BYTES + 1 - \strlen($bytes));
            if ($read === '') {
                break;
            }
            $bytes .= $read;
        }

        return $bytes;
    }

    private static function tooLarge(ResponseInterface $response): ResponseInterface
    {
        return Problem::write(
            $response,
            413,
            'payload_too_large',
            'Too large',
            'A chunk is at most 4 MiB and a file at most 100 MiB.',
        );
    }
}
