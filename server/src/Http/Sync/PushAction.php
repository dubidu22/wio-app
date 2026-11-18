<?php

declare(strict_types=1);

namespace Wio\Http\Sync;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use stdClass;
use Wio\Auth\AuthContext;
use Wio\Http\InvalidRequest;
use Wio\Http\Json;
use Wio\Http\Problem;
use Wio\Sync\Change;
use Wio\Sync\ChangeResult;
use Wio\Sync\Push;

/**
 * POST /sync/push (syncPush). The envelope is checked here (D-93: no
 * run-time contract validation); each change is answered by Push.
 */
final class PushAction
{
    /**
     * @param \Closure(): Push $push
     */
    public function __construct(private readonly \Closure $push) {}

    public function __invoke(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $caller = AuthContext::of($request);
        $type = strtolower(trim(explode(';', $request->getHeaderLine('Content-Type'))[0]));
        if ($type !== 'application/json') {
            throw new InvalidRequest('The body must be application/json.');
        }
        $raw = (string) $request->getBody();
        if (\strlen($raw) > Push::MAX_BYTES) {
            return Problem::write($response, 413, 'payload_too_large', 'Request too large', 'A push body may hold at most 2 MiB; send fewer changes.');
        }
        try {
            $body = json_decode($raw, false, 64, JSON_THROW_ON_ERROR);
        } catch (\JsonException) {
            throw new InvalidRequest('The body is not valid JSON.');
        }
        if (!$body instanceof stdClass || array_keys(get_object_vars($body)) !== ['changes']) {
            throw new InvalidRequest('The body must be an object with only `changes`.');
        }
        $items = $body->changes;
        if (!\is_array($items) || !array_is_list($items) || $items === []) {
            throw new InvalidRequest('changes must be a list of at least one change.');
        }
        if (\count($items) > Push::MAX_CHANGES) {
            return Problem::write($response, 413, 'too_many_changes', 'Too many changes', 'A push may hold at most 200 changes.');
        }
        $changes = [];
        foreach ($items as $index => $item) {
            $changes[] = Change::fromJson($item, $index);
        }

        $results = ($this->push)()->push($caller, $changes);

        return Json::write($response, ['results' => array_map(static fn(ChangeResult $r): array => $r->toJson(), $results)]);
    }
}
