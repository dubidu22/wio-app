<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Http;

use PHPUnit\Framework\TestCase;
use Wio\Http\Cors;

/**
 * Parsing `WIO_CORS_ORIGINS` (D-164), plan 010 addendum test K6.
 */
final class CorsConfigTest extends TestCase
{
    public function testExactOriginsAreKeptTrimmedAndLowerCased(): void
    {
        $cors = Cors::fromConfig(' https://App.Example.org , https://web.example.org:8443,,http://localhost:8080 ');

        self::assertSame(['https://app.example.org', 'https://web.example.org:8443', 'http://localhost:8080'], $cors->origins);
        self::assertSame([], $cors->dropped);
        self::assertTrue($cors->allows('https://APP.example.org'));
        self::assertFalse($cors->allows('https://app.example.org.evil.test'));
        self::assertFalse($cors->allows('https://example.org'));
    }

    public function testForbiddenFormsAreDropped(): void
    {
        $entries = [
            '*',
            'null',
            'https://*.example.org',
            'https://app.example.org/',
            'https://app.example.org/web',
            'http://app.example.org',
            'http://localhost',
            'http://127.0.0.1:8080',
            'app.example.org',
            'https://',
            'https://-bad.example.org',
            'https://app.example.org:123456',
        ];

        $cors = Cors::fromConfig(implode(',', $entries));

        self::assertSame([], $cors->origins);
        self::assertSame($entries, $cors->dropped);
        foreach ($entries as $entry) {
            self::assertFalse($cors->allows($entry), $entry);
        }
    }

    public function testEmptyMeansNoOrigins(): void
    {
        self::assertSame([], Cors::fromConfig('')->origins);
        self::assertSame([], Cors::fromConfig(' , ')->origins);
    }
}
