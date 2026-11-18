<?php

declare(strict_types=1);

namespace Wio\Files;

use Wio\Http\InvalidRequest;

/**
 * The `Content-Range: bytes <first>-<last>/<total>` of one chunk
 * (putFileChunk). Numbers have no leading zeros; first <= last < total.
 */
final readonly class ContentRange
{
    private const string PATTERN = '/^bytes (0|[1-9][0-9]{0,14})-(0|[1-9][0-9]{0,14})\/([1-9][0-9]{0,14})$/';

    private function __construct(
        public int $first,
        public int $last,
        public int $total,
    ) {}

    /**
     * @throws InvalidRequest
     */
    public static function parse(string $header): self
    {
        if (preg_match(self::PATTERN, $header, $m) !== 1) {
            throw new InvalidRequest('Content-Range must be "bytes <first>-<last>/<total>" without leading zeros.');
        }
        [$first, $last, $total] = [(int) $m[1], (int) $m[2], (int) $m[3]];
        if ($first > $last || $last >= $total) {
            throw new InvalidRequest('Content-Range needs first <= last < total.');
        }

        return new self($first, $last, $total);
    }

    public function length(): int
    {
        return $this->last - $this->first + 1;
    }
}
