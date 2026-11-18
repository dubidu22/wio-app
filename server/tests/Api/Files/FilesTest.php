<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Files;

use Psr\Http\Message\ResponseInterface;
use Wio\Files\FileStore;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 tests F1 (upload, D-185, D-186) and F2 (partial cleanup, S16),
 * with the store locking of D-207 and the helper answer of D-206. Every file
 * is invented bytes.
 */
#[Operation('getFileState')]
#[Operation('putFileChunk')]
final class FilesTest extends DatabaseTestCase
{
    private const int MIB = 1048576;

    private string $workspace;

    private string $token;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->fixtures->workspace();
        $this->token = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace))['token'];
    }

    public function testTheLimitsAreTheContractsAndThePlans(): void
    {
        self::assertSame(4 * self::MIB, FileStore::MAX_CHUNK_BYTES);
        self::assertSame(100 * self::MIB, FileStore::MAX_FILE_BYTES);
        self::assertSame(7, FileStore::PARTIAL_DAYS);
        self::assertSame(20, FileStore::PURGE_LIMIT);
    }

    public function testAnUnknownFileHasNoBytes(): void
    {
        self::assertSame(['sha256' => self::sha('nichts'), 'size' => null, 'received_bytes' => 0, 'complete' => false], $this->state(self::sha('nichts')));
        self::assertDirectoryDoesNotExist($this->filesDir . '/' . $this->workspace, 'reading the state creates nothing');
    }

    public function testNineMegabytesInThreeChunks(): void
    {
        $file = random_bytes(9000000);
        $sha = hash('sha256', $file);

        $first = $this->put($sha, substr($file, 0, 4 * self::MIB), 0, 9000000);
        self::assertSame(202, $first->getStatusCode());
        self::assertSame(['sha256' => $sha, 'size' => 9000000, 'received_bytes' => 4 * self::MIB, 'complete' => false], self::json($first));
        self::assertSame(['sha256' => $sha, 'size' => 9000000, 'received_bytes' => 4 * self::MIB, 'complete' => false], $this->state($sha));
        $second = $this->put($sha, substr($file, 4 * self::MIB, 4 * self::MIB), 4 * self::MIB, 9000000);
        self::assertSame(202, $second->getStatusCode());
        self::assertSame(8 * self::MIB, self::json($second)['received_bytes'] ?? null);
        $last = $this->put($sha, substr($file, 8 * self::MIB), 8 * self::MIB, 9000000);

        self::assertSame(200, $last->getStatusCode());
        $complete = ['sha256' => $sha, 'size' => 9000000, 'received_bytes' => 9000000, 'complete' => true];
        self::assertSame($complete, self::json($last));
        self::assertSame($complete, $this->state($sha));
        self::assertSame($file, file_get_contents($this->filesDir . '/' . $this->workspace . '/' . $sha));
        self::assertSame([], glob($this->filesDir . '/' . $this->workspace . '/*.part'));
    }

    public function testAnInterruptedUploadResumesFromTheState(): void
    {
        $file = random_bytes(5 * self::MIB);
        $sha = hash('sha256', $file);
        $this->put($sha, substr($file, 0, 3 * self::MIB), 0, \strlen($file));

        // The app lost its place: it asks, and goes on from there.
        $from = $this->state($sha)['received_bytes'];
        self::assertSame(3 * self::MIB, $from);
        $last = $this->put($sha, substr($file, $from), $from, \strlen($file));

        self::assertSame(200, $last->getStatusCode());
        self::assertSame($file, file_get_contents($this->filesDir . '/' . $this->workspace . '/' . $sha));
    }

    public function testAChunkThatDoesNotStartAtTheReceivedSizeIs409WithTheSizeToResumeFrom(): void
    {
        $file = random_bytes(3000);
        $sha = hash('sha256', $file);
        $ahead = $this->put($sha, substr($file, 1000, 1000), 1000, 3000);
        self::assertProblem($ahead, 409, 'offset_mismatch');
        self::assertSame(0, self::json($ahead)['received_bytes'] ?? null);

        $this->put($sha, substr($file, 0, 2000), 0, 3000);
        foreach ([0, 1000, 2500] as $start) {
            $wrong = $this->put($sha, substr($file, $start, 500), $start, 3000);
            self::assertProblem($wrong, 409, 'offset_mismatch');
            self::assertSame(2000, self::json($wrong)['received_bytes'] ?? null, "start {$start}");
        }
        self::assertSame(2000, $this->state($sha)['received_bytes'], 'a refused chunk writes nothing');
        self::assertSame(200, $this->put($sha, substr($file, 2000), 2000, 3000)->getStatusCode());
    }

    public function testAWrongHashIs422AndThePartialFileIsGone(): void
    {
        $file = random_bytes(3000);
        $sha = self::sha('etwas anderes');
        self::assertSame(202, $this->put($sha, substr($file, 0, 2000), 0, 3000)->getStatusCode());

        self::assertProblem($this->put($sha, substr($file, 2000), 2000, 3000), 422, 'hash_mismatch');

        self::assertSame(['sha256' => $sha, 'size' => null, 'received_bytes' => 0, 'complete' => false], $this->state($sha));
        self::assertSame([], glob($this->filesDir . '/' . $this->workspace . '/' . $sha . '*'));
        // The app can start again from 0 with the right bytes.
        $right = hash('sha256', $file);
        self::assertSame(200, $this->put($right, $file, 0, 3000)->getStatusCode());
    }

    public function testAChunkOver4MiBAndAFileOver100MiBAre413(): void
    {
        $sha = self::sha('groß');
        $chunk = str_repeat('x', 4 * self::MIB + 1);
        self::assertProblem($this->put($sha, $chunk, 0, 9000000), 413, 'payload_too_large');
        // A Content-Range that claims less than the body sends is caught too.
        self::assertProblem($this->send($this->chunk($sha, $chunk, 0, 9000000, $this->token, range: 'bytes 0-99/9000000')), 413, 'payload_too_large');
        self::assertProblem($this->put($sha, 'x', 0, 100 * self::MIB + 1), 413, 'payload_too_large');

        self::assertSame(100 * self::MIB, FileStore::MAX_FILE_BYTES, 'exactly 100 MiB is allowed');
        self::assertSame(202, $this->put($sha, 'x', 0, 100 * self::MIB)->getStatusCode());
        self::assertSame(1, $this->state($sha)['received_bytes']);
    }

    public function testARepeatOfACompleteFileIs200(): void
    {
        $file = random_bytes(3000);
        $sha = hash('sha256', $file);
        self::assertSame(200, $this->put($sha, $file, 0, 3000)->getStatusCode());

        foreach ([[0, $file], [1000, substr($file, 1000)]] as [$start, $bytes]) {
            $again = $this->put($sha, $bytes, $start, 3000);
            self::assertSame(200, $again->getStatusCode());
            self::assertSame(['sha256' => $sha, 'size' => 3000, 'received_bytes' => 3000, 'complete' => true], self::json($again));
        }
        self::assertSame($file, file_get_contents($this->filesDir . '/' . $this->workspace . '/' . $sha));
    }

    public function testFilesArePerWorkspace(): void
    {
        $file = random_bytes(3000);
        $sha = hash('sha256', $file);
        $this->put($sha, $file, 0, 3000);
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $otherToken = $this->fixtures->token($other, $this->fixtures->user($other, email: 'andere@example.org'))['token'];

        self::assertSame(['sha256' => $sha, 'size' => null, 'received_bytes' => 0, 'complete' => false], $this->state($sha, $otherToken), 'never tells that another workspace holds the file');
        $first = $this->send($this->chunk($sha, substr($file, 0, 1000), 0, 3000, $otherToken));
        self::assertSame(202, $first->getStatusCode(), 'the other workspace uploads its own copy');
        self::assertSame(1000, self::json($first)['received_bytes'] ?? null);
    }

    public function testATotalThatDiffersFromTheFirstChunksIs400(): void
    {
        $file = random_bytes(3000);
        $sha = hash('sha256', $file);
        $this->put($sha, substr($file, 0, 1000), 0, 3000);

        self::assertProblem($this->put($sha, substr($file, 1000, 1000), 1000, 3001), 400, 'invalid_request');
        self::assertSame(['sha256' => $sha, 'size' => 3000, 'received_bytes' => 1000, 'complete' => false], $this->state($sha));
    }

    public function testARangeThatDoesNotFitItselfOrTheBodyIs400(): void
    {
        $sha = self::sha('Bereich');
        foreach ([
            'last before first' => ['bytes 10-9/100', ''],
            'last beyond the total' => ['bytes 0-100/100', str_repeat('x', 101)],
            'body shorter than the range' => ['bytes 0-9/100', 'xxxxx'],
            'body longer than the range' => ['bytes 0-4/100', 'xxxxxxxxxx'],
            'empty body' => ['bytes 0-0/100', ''],
            'zero total' => ['bytes 0-0/0', 'x'],
            'leading zeros' => ['bytes 00-4/100', 'xxxxx'],
        ] as $case => [$range, $body]) {
            $response = $this->send($this->chunk($sha, $body, 0, 100, $this->token, range: $range));
            self::assertProblem($response, 400, 'invalid_request');
            self::assertSame(0, $this->state($sha)['received_bytes'], $case);
        }
    }

    public function testAMalformedHashOrRangeBreaksTheContractAndIs400(): void
    {
        $upper = strtoupper(self::sha('x'));
        self::assertProblem($this->sendInvalid($this->call('GET', '/files/' . $upper . '/state', token: $this->token), 'getFileState'), 400, 'invalid_request');
        self::assertProblem($this->sendInvalid($this->chunk($upper, 'x', 0, 1, $this->token), 'putFileChunk'), 400, 'invalid_request');
        self::assertProblem($this->sendInvalid($this->chunk(self::sha('x'), 'x', 0, 1, $this->token, range: 'bytes=0-0/1'), 'putFileChunk'), 400, 'invalid_request');
        self::assertProblem($this->sendInvalid($this->call('PUT', '/files/' . self::sha('x'), token: $this->token), 'putFileChunk'), 400, 'invalid_request');
    }

    public function testCustomersUploadAndHelpersGet403(): void
    {
        $customer = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org'))['token'];
        $helper = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'helper', 'helfer@example.org'))['token'];

        $upload = $this->send($this->chunk(self::sha('Kiste'), 'Kiste', 0, 5, $customer));
        self::assertSame(200, $upload->getStatusCode(), (string) $upload->getBody());
        self::assertProblem($this->send($this->chunk(self::sha('Tasche'), 'Tasche', 0, 6, $helper)), 403, 'forbidden');
        self::assertProblem($this->send($this->call('GET', '/files/' . self::sha('Kiste') . '/state', token: $helper)), 403, 'forbidden');
        self::assertFileDoesNotExist($this->filesDir . '/' . $this->workspace . '/' . self::sha('Tasche'));
    }

    public function testPartialFilesOlderThanSevenDaysAreDeletedDuringUploadsTwentyAtATime(): void
    {
        $now = $this->clock->now()->getTimestamp();
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $old = [];
        foreach ([$this->workspace => 12, $other => 10] as $workspace => $count) {
            for ($i = 0; $i < $count; ++$i) {
                $old[] = $this->file($workspace, self::sha("alt {$workspace} {$i}") . '.100.part', $now - 8 * 86400);
            }
        }
        $young = $this->file($this->workspace, self::sha('jung') . '.100.part', $now - 6 * 86400);
        $complete = $this->file($other, self::sha('fertig'), $now - 30 * 86400);
        $foreign = $this->file($this->workspace, 'notiz.txt', $now - 30 * 86400);
        $foreignPart = $this->file($this->workspace, 'notiz.part', $now - 30 * 86400);

        self::assertSame(200, $this->put(self::sha('Kiste'), 'Kiste', 0, 5)->getStatusCode());
        $left = array_values(array_filter($old, 'file_exists'));
        self::assertCount(2, $left, 'at most 20 per request');

        $this->state(self::sha('Kiste'));
        self::assertCount(2, array_filter($old, 'file_exists'), 'reading the state deletes nothing');

        self::assertSame(200, $this->put(self::sha('Tasche'), 'Tasche', 0, 6)->getStatusCode());
        self::assertSame([], array_values(array_filter($old, 'file_exists')));
        self::assertFileExists($young, 'six days old stays');
        self::assertFileExists($complete, 'complete files are never cleaned up');
        self::assertFileExists($foreign, 'only partial files are cleaned up');
        self::assertFileExists($foreignPart, 'only partial files the store made are cleaned up');
    }

    public function testAPartialFileOfAnUploadInProgressIsKeptAndResumes(): void
    {
        $file = random_bytes(3000);
        $sha = hash('sha256', $file);
        $this->put($sha, substr($file, 0, 1000), 0, 3000);
        $this->clock->advance('P6D');
        self::assertSame(202, $this->put($sha, substr($file, 1000, 1000), 1000, 3000)->getStatusCode());
        $this->clock->advance('P6D');

        // Twelve days after the start, but six after the last chunk.
        self::assertSame(200, $this->put(self::sha('Kiste'), 'Kiste', 0, 5)->getStatusCode());
        self::assertSame(200, $this->put($sha, substr($file, 2000), 2000, 3000)->getStatusCode());
    }

    private static function sha(string $content): string
    {
        return hash('sha256', $content);
    }

    private function put(string $sha256, string $bytes, int $start, int $total): ResponseInterface
    {
        return $this->send($this->chunk($sha256, $bytes, $start, $total, $this->token));
    }

    /**
     * @return array<string, mixed>
     */
    private function state(string $sha256, ?string $token = null): array
    {
        $response = $this->send($this->call('GET', '/files/' . $sha256 . '/state', token: $token ?? $this->token));
        self::assertSame(200, $response->getStatusCode(), (string) $response->getBody());

        return self::json($response);
    }

    private function file(string $workspace, string $name, int $modified): string
    {
        $dir = $this->filesDir . '/' . $workspace;
        if (!is_dir($dir)) {
            mkdir($dir, 0o700, true);
        }
        $path = $dir . '/' . $name;
        file_put_contents($path, 'x');
        touch($path, $modified);

        return $path;
    }
}
