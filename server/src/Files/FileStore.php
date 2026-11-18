<?php

declare(strict_types=1);

namespace Wio\Files;

use Psr\Clock\ClockInterface;
use RuntimeException;
use Wio\Http\InvalidRequest;

/**
 * The file store of plan 006 (D-185, D-186, D-207): `<root>/<workspace_id>/
 * <sha256>` for a complete file, `<sha256>.<total>.part` while chunks arrive,
 * so the total of the first chunk survives between requests. One lock file
 * per workspace (`.lock`, flock) serialises chunk writes and state reads, so
 * parallel uploads cannot interleave. Partial files untouched for seven days
 * are deleted during uploads (S16); their time is the clock's, set after
 * every chunk.
 *
 * Paths are built only from a workspace id and a hash that match their
 * patterns here, never from another submitted string.
 *
 * @phpstan-type State array{sha256: string, size: int|null, received_bytes: int<0, max>, complete: bool}
 */
final class FileStore
{
    public const int MAX_CHUNK_BYTES = 4 * 1024 * 1024;

    public const int MAX_FILE_BYTES = 100 * 1024 * 1024;

    public const int PARTIAL_DAYS = 7;

    public const int PURGE_LIMIT = 20;

    private const string SHA256 = '/^[0-9a-f]{64}$/';

    private const string WORKSPACE = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/';

    private const string PART = '/^([0-9a-f]{64})\.([1-9][0-9]{0,14})\.part$/';

    public function __construct(
        private readonly string $root,
        private readonly ClockInterface $clock,
    ) {
        if ($root === '') {
            throw new RuntimeException('WIO_FILES_DIR is not set.');
        }
    }

    /**
     * @return State
     */
    public function state(string $workspaceId, string $sha256): array
    {
        $dir = $this->dir($workspaceId);
        self::checkSha($sha256);
        if (!is_dir($dir)) {
            return self::answer($sha256, null, 0, false);
        }

        return $this->locked($dir, LOCK_SH, fn(): array => self::read($dir, $sha256));
    }

    /**
     * Appends one chunk whose size and range the caller has checked against
     * the limits. A chunk for a complete file changes nothing.
     *
     * @return State
     *
     * @throws InvalidRequest when the total differs from the first chunk's
     * @throws OffsetMismatch
     * @throws HashMismatch
     */
    public function put(string $workspaceId, string $sha256, ContentRange $range, string $bytes): array
    {
        $dir = $this->dir($workspaceId);
        self::checkSha($sha256);
        if (\strlen($bytes) !== $range->length() || $range->length() > self::MAX_CHUNK_BYTES || $range->total > self::MAX_FILE_BYTES) {
            throw new \LogicException('The chunk was not checked against its range and the limits.');
        }
        if (!is_dir($dir) && !@mkdir($dir, 0o700, true) && !is_dir($dir)) {
            throw new RuntimeException('Cannot create the workspace file directory.');
        }
        $this->purge();

        return $this->locked($dir, LOCK_EX, function () use ($dir, $sha256, $range, $bytes): array {
            $state = self::read($dir, $sha256);
            if ($state['complete']) {
                return $state;
            }
            if ($state['size'] !== null && $state['size'] !== $range->total) {
                throw new InvalidRequest("The total differs from the first chunk's total of {$state['size']} bytes.");
            }
            if ($range->first !== $state['received_bytes']) {
                throw new OffsetMismatch($state['received_bytes']);
            }

            $part = "{$dir}/{$sha256}.{$range->total}.part";
            $this->append($part, $bytes, $state['received_bytes']);
            $received = $state['received_bytes'] + \strlen($bytes);
            if ($received < $range->total) {
                return self::answer($sha256, $range->total, $received, false);
            }
            if (hash_file('sha256', $part) !== $sha256) {
                unlink($part);

                throw new HashMismatch('The file does not match its SHA-256.');
            }
            if (!rename($part, "{$dir}/{$sha256}")) {
                throw new RuntimeException('Cannot move a complete file into place.');
            }

            return self::answer($sha256, $range->total, $received, true);
        });
    }

    /**
     * Deletes partial files older than PARTIAL_DAYS in every workspace, at
     * most PURGE_LIMIT, skipping a workspace whose lock is held.
     */
    private function purge(): void
    {
        $cutoff = $this->clock->now()->getTimestamp() - self::PARTIAL_DAYS * 86400;
        $deleted = 0;
        foreach (self::glob($this->root . '/*', GLOB_ONLYDIR) as $dir) {
            if (preg_match(self::WORKSPACE, basename($dir)) !== 1) {
                continue;
            }
            $old = array_filter(
                self::glob($dir . '/*.part'),
                static fn(string $path): bool => preg_match(self::PART, basename($path)) === 1 && self::modified($path) < $cutoff,
            );
            if ($old === []) {
                continue;
            }
            $lock = fopen($dir . '/.lock', 'c');
            if ($lock === false) {
                continue;
            }
            try {
                if (!flock($lock, LOCK_EX | LOCK_NB)) {
                    continue;
                }
                foreach ($old as $path) {
                    clearstatcache(true, $path);
                    if (self::modified($path) < $cutoff && @unlink($path) && ++$deleted >= self::PURGE_LIMIT) {
                        return;
                    }
                }
            } finally {
                flock($lock, LOCK_UN);
                fclose($lock);
            }
        }
    }

    /**
     * @param int<0, max> $received
     */
    private function append(string $part, string $bytes, int $received): void
    {
        $handle = fopen($part, 'c+b');
        if ($handle === false) {
            throw new RuntimeException('Cannot open a partial file.');
        }
        try {
            fseek($handle, $received);
            $written = fwrite($handle, $bytes);
            if ($written !== \strlen($bytes) || !fflush($handle)) {
                ftruncate($handle, $received);

                throw new RuntimeException('Cannot write a chunk.');
            }
        } finally {
            fclose($handle);
        }
        touch($part, $this->clock->now()->getTimestamp());
    }

    /**
     * @template T
     *
     * @param LOCK_SH|LOCK_EX $mode
     * @param \Closure(): T $work
     *
     * @return T
     */
    private function locked(string $dir, int $mode, \Closure $work): mixed
    {
        $lock = fopen($dir . '/.lock', 'c');
        if ($lock === false || !flock($lock, $mode)) {
            throw new RuntimeException('Cannot lock the workspace file directory.');
        }
        try {
            clearstatcache();

            return $work();
        } finally {
            flock($lock, LOCK_UN);
            fclose($lock);
        }
    }

    /**
     * @return State
     */
    private static function read(string $dir, string $sha256): array
    {
        $complete = "{$dir}/{$sha256}";
        if (is_file($complete)) {
            $size = filesize($complete);
            if ($size === false) {
                throw new RuntimeException('Cannot read a file size.');
            }

            return self::answer($sha256, $size, $size, true);
        }
        foreach (self::glob("{$dir}/{$sha256}.*.part") as $part) {
            if (preg_match(self::PART, basename($part), $m) === 1) {
                $received = filesize($part);
                if ($received === false) {
                    throw new RuntimeException('Cannot read a file size.');
                }

                return self::answer($sha256, (int) $m[2], $received, false);
            }
        }

        return self::answer($sha256, null, 0, false);
    }

    /**
     * @param int<0, max> $received
     *
     * @return State
     */
    private static function answer(string $sha256, ?int $size, int $received, bool $complete): array
    {
        return ['sha256' => $sha256, 'size' => $size, 'received_bytes' => $received, 'complete' => $complete];
    }

    private function dir(string $workspaceId): string
    {
        if (preg_match(self::WORKSPACE, $workspaceId) !== 1) {
            throw new \LogicException('A workspace id is not a lower-case UUID.');
        }

        return $this->root . '/' . $workspaceId;
    }

    private static function checkSha(string $sha256): void
    {
        if (preg_match(self::SHA256, $sha256) !== 1) {
            throw new \LogicException('A hash is not lower-case hex SHA-256.');
        }
    }

    /**
     * @return list<string>
     */
    private static function glob(string $pattern, int $flags = 0): array
    {
        $paths = glob($pattern, $flags);

        return $paths === false ? [] : $paths;
    }

    private static function modified(string $path): int
    {
        $time = @filemtime($path);

        return $time === false ? PHP_INT_MAX : $time;
    }
}
