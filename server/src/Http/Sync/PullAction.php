<?php

declare(strict_types=1);

namespace Wio\Http\Sync;

use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Wio\Auth\AuthContext;
use Wio\Http\InvalidRequest;
use Wio\Http\Json;
use Wio\Http\Problem;
use Wio\Sync\Pull;
use Wio\Sync\ResyncRequired;

/**
 * GET /sync/pull (syncPull).
 */
final class PullAction
{
    private const int MAX_SAFE_INTEGER = 9007199254740991;

    /**
     * @param \Closure(): Pull $pull
     */
    public function __construct(private readonly \Closure $pull) {}

    public function __invoke(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $caller = AuthContext::of($request);
        $query = $request->getQueryParams();
        $since = self::integer($query['since'] ?? null, 'since', 0, self::MAX_SAFE_INTEGER);
        $limit = \array_key_exists('limit', $query) ? self::integer($query['limit'], 'limit', 1, Pull::MAX_LIMIT) : Pull::MAX_LIMIT;

        try {
            $page = ($this->pull)()->page($caller, $since, $limit);
        } catch (ResyncRequired) {
            return Problem::write(
                $response,
                410,
                'resync_required',
                'Sync again from the start',
                'Drop pulled records, keep the outbox, and pull again from since=0.',
            );
        }

        return Json::write($response, $page);
    }

    private static function integer(mixed $value, string $name, int $min, int $max): int
    {
        if (!\is_string($value) || preg_match('/^(0|[1-9][0-9]{0,15})$/', $value) !== 1 || (int) $value < $min || (int) $value > $max) {
            throw new InvalidRequest("{$name} must be a whole number from {$min} to {$max}.");
        }

        return (int) $value;
    }
}
