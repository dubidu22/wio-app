<?php

declare(strict_types=1);

namespace Wio\Files;

use Psr\Http\Message\StreamInterface;
use RuntimeException;

/**
 * A read-only stream over part of an open file (D-231): bytes `start` to
 * `start + length - 1`, read in the pieces the caller asks for, so a large
 * download never sits in memory. Positions are relative to `start`.
 */
final class FileRangeStream implements StreamInterface
{
    /** @var resource|null */
    private $handle;

    private int $position = 0;

    /**
     * @param resource $handle
     * @param int<0, max> $start
     * @param int<0, max> $length
     */
    public function __construct($handle, private readonly int $start, private readonly int $length)
    {
        $this->handle = $handle;
    }

    public function __toString(): string
    {
        if ($this->handle === null) {
            return '';
        }
        $this->rewind();

        return $this->getContents();
    }

    public function close(): void
    {
        if ($this->handle !== null) {
            fclose($this->handle);
            $this->handle = null;
        }
    }

    public function detach()
    {
        $handle = $this->handle;
        $this->handle = null;

        return $handle;
    }

    public function getSize(): int
    {
        return $this->length;
    }

    public function tell(): int
    {
        $this->open();

        return $this->position;
    }

    public function eof(): bool
    {
        return $this->handle === null || $this->position >= $this->length;
    }

    public function isSeekable(): bool
    {
        return $this->handle !== null;
    }

    public function seek(int $offset, int $whence = SEEK_SET): void
    {
        $handle = $this->open();
        $target = match ($whence) {
            SEEK_SET => $offset,
            SEEK_CUR => $this->position + $offset,
            SEEK_END => $this->length + $offset,
            default => throw new RuntimeException('Unknown seek mode.'),
        };
        if ($target < 0 || $target > $this->length) {
            throw new RuntimeException('Cannot seek outside the range.');
        }
        if (fseek($handle, $this->start + $target) !== 0) {
            throw new RuntimeException('Cannot seek in the file.');
        }
        $this->position = $target;
    }

    public function rewind(): void
    {
        $this->seek(0);
    }

    public function isWritable(): bool
    {
        return false;
    }

    public function write(string $string): int
    {
        throw new RuntimeException('A download stream is read-only.');
    }

    public function isReadable(): bool
    {
        return $this->handle !== null;
    }

    public function read(int $length): string
    {
        $handle = $this->open();
        $wanted = min($length, $this->length - $this->position);
        if ($wanted <= 0) {
            return '';
        }
        if (ftell($handle) !== $this->start + $this->position) {
            fseek($handle, $this->start + $this->position);
        }
        $bytes = fread($handle, $wanted);
        if ($bytes === false) {
            throw new RuntimeException('Cannot read the file.');
        }
        if ($bytes === '') {
            // The file is shorter than its range: stop instead of spinning.
            $this->position = $this->length;

            return '';
        }
        $this->position += \strlen($bytes);

        return $bytes;
    }

    public function getContents(): string
    {
        $out = '';
        while (!$this->eof()) {
            $piece = $this->read(65536);
            if ($piece === '') {
                break;
            }
            $out .= $piece;
        }

        return $out;
    }

    public function getMetadata(?string $key = null): mixed
    {
        if ($this->handle === null) {
            return $key === null ? [] : null;
        }
        $meta = stream_get_meta_data($this->handle);

        return $key === null ? $meta : ($meta[$key] ?? null);
    }

    /**
     * @return resource
     */
    private function open()
    {
        if ($this->handle === null) {
            throw new RuntimeException('The stream is closed.');
        }

        return $this->handle;
    }
}
