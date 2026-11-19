<?php

declare(strict_types=1);

namespace Wio\Http;

/**
 * The CORS allow-list from `WIO_CORS_ORIGINS` (D-164): exact `https` origins,
 * plus a full `http://localhost:<port>` for local and staging configs.
 * Production's value never lists localhost. Anything else is dropped: `*`,
 * `null`, wildcards, paths, trailing slashes and other `http` origins.
 */
final readonly class Cors
{
    /** The contract's methods (D-169); a test keeps them equal. */
    public const array METHODS = ['GET', 'POST', 'PUT', 'DELETE'];

    /** Request headers the app sends that are not CORS-safelisted (D-165, D-234). */
    public const array HEADERS = ['Authorization', 'Content-Type', 'Content-Range', 'Wio-App-Version', 'Range', 'If-None-Match', 'If-Range'];

    /** Response headers the web app must read (D-166, D-234): the 429 wait and the download's range and validator. */
    public const array EXPOSE = ['Retry-After', 'Content-Range', 'ETag', 'Accept-Ranges', 'Content-Disposition'];

    public const int MAX_AGE = 600;

    private const string HOST = '[a-z0-9](?:[a-z0-9-]*[a-z0-9])?(?:\.[a-z0-9](?:[a-z0-9-]*[a-z0-9])?)*';

    /**
     * @param list<string> $origins allowed origins, lower case
     * @param list<string> $dropped config entries that are not allowed origins
     */
    private function __construct(
        public array $origins,
        public array $dropped,
    ) {}

    public static function fromConfig(string $value): self
    {
        $origins = [];
        $dropped = [];
        foreach (explode(',', $value) as $entry) {
            $entry = strtolower(trim($entry));
            if ($entry === '') {
                continue;
            }
            if (self::isOrigin($entry)) {
                $origins[] = $entry;
            } else {
                $dropped[] = $entry;
            }
        }

        return new self(array_values(array_unique($origins)), $dropped);
    }

    /**
     * Whether a request's `Origin` header is on the list. Compared exactly,
     * after lower-casing; never by prefix.
     */
    public function allows(string $origin): bool
    {
        return \in_array(strtolower($origin), $this->origins, true);
    }

    private static function isOrigin(string $entry): bool
    {
        return preg_match('#^https://' . self::HOST . '(?::[0-9]{1,5})?$#D', $entry) === 1
            || preg_match('#^http://localhost:[0-9]{1,5}$#D', $entry) === 1;
    }
}
