<?php

declare(strict_types=1);

namespace Wio\Files;

/**
 * One byte range of a download (D-230, RFC 9110 section 14): `bytes=a-b`,
 * `bytes=a-` or `bytes=-n`, resolved against the file's size.
 */
final class ByteRange
{
    /**
     * @param int<0, max> $first
     * @param int<0, max> $last
     */
    private function __construct(
        public readonly int $first,
        public readonly int $last,
    ) {}

    /**
     * @return int<1, max>
     */
    public function length(): int
    {
        return max(1, $this->last - $this->first + 1);
    }

    /**
     * The range to send, null for the whole file (no header, several ranges,
     * or a header this server does not read, which RFC 9110 lets it ignore),
     * or false when the one range cannot be satisfied (416).
     *
     * @param int<0, max> $size
     */
    public static function parse(string $header, int $size): self|false|null
    {
        if (preg_match('/^\s*bytes\s*=\s*([0-9]{0,15})\s*-\s*([0-9]{0,15})\s*$/i', $header, $m) !== 1) {
            return null;
        }
        [, $from, $to] = $m;
        if ($from === '' && $to === '') {
            return null;
        }
        if ($from === '') {
            $suffix = (int) $to;
            if ($suffix === 0 || $size === 0) {
                return false;
            }

            return new self(max(0, $size - $suffix), $size - 1);
        }
        $first = max(0, (int) $from);
        if ($to !== '' && (int) $to < $first) {
            return null;
        }
        if ($first >= $size) {
            return false;
        }

        return new self($first, max($first, $to === '' ? $size - 1 : min((int) $to, $size - 1)));
    }
}
