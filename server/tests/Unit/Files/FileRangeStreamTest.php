<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Files;

use PHPUnit\Framework\TestCase;
use RuntimeException;
use Wio\Files\FileRangeStream;

/**
 * Plan 055 T11: the read-only stream over part of a file (D-231).
 */
final class FileRangeStreamTest extends TestCase
{
    public function testReadsOnlyItsRangeInPieces(): void
    {
        $stream = new FileRangeStream(self::file('0123456789'), 2, 5);

        self::assertSame(5, $stream->getSize());
        self::assertTrue($stream->isReadable());
        self::assertTrue($stream->isSeekable());
        self::assertFalse($stream->isWritable());
        self::assertSame('23', $stream->read(2));
        self::assertSame(2, $stream->tell());
        self::assertSame('456', $stream->read(100));
        self::assertTrue($stream->eof());
        self::assertSame('', $stream->read(1));
        self::assertSame('23456', (string) $stream, 'casting starts over');
    }

    public function testSeeksWithinTheRange(): void
    {
        $stream = new FileRangeStream(self::file('0123456789'), 2, 5);

        $stream->seek(3);
        self::assertSame('56', $stream->getContents());
        $stream->seek(-2, SEEK_END);
        self::assertSame('5', $stream->read(1));
        $stream->seek(-1, SEEK_CUR);
        self::assertSame('56', $stream->getContents());
        $stream->rewind();
        self::assertSame('2', $stream->read(1));

        $this->expectException(RuntimeException::class);
        $stream->seek(6);
    }

    public function testAFileShorterThanItsRangeEnds(): void
    {
        $stream = new FileRangeStream(self::file('0123'), 2, 5);

        self::assertSame('23', $stream->getContents());
        self::assertTrue($stream->eof());
    }

    public function testIsReadOnlyAndCloses(): void
    {
        $stream = new FileRangeStream(self::file('abc'), 0, 3);
        self::assertSame('w+b', $stream->getMetadata('mode'));
        $stream->close();

        self::assertTrue($stream->eof());
        self::assertSame('', (string) $stream);
        self::assertSame([], $stream->getMetadata());
        self::assertNull($stream->detach());
        $this->expectException(RuntimeException::class);
        $stream->write('x');
    }

    /**
     * @return resource
     */
    private static function file(string $bytes)
    {
        $handle = fopen('php://memory', 'w+b');
        self::assertNotFalse($handle);
        fwrite($handle, $bytes);
        rewind($handle);

        return $handle;
    }
}
