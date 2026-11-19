<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Files;

use Psr\Http\Message\ServerRequestInterface;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;
use Wio\Tests\Db\Schema\Rows;

/**
 * Plan 055 tests T1 to T10 for getFile (D-224 to D-232). Every file is
 * invented bytes.
 */
#[Operation('getFile')]
#[Operation('putFileChunk')]
final class DownloadTest extends DatabaseTestCase
{
    private Rows $rows;

    private string $workspace;

    private string $owner;

    protected function setUp(): void
    {
        parent::setUp();
        $this->rows = new Rows($this->sql->pdo);
        $this->workspace = $this->fixtures->workspace();
        $this->owner = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace))['token'];
    }

    public function testTheOwnerDownloadsAPictureWithItsHeaders(): void
    {
        $bytes = random_bytes(3000);
        $sha = $this->stored($this->workspace, $bytes);
        $this->picture($this->workspace, null, $sha);

        $response = $this->send($this->get($sha, $this->owner));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame($bytes, (string) $response->getBody());
        self::assertSame('image/jpeg', $response->getHeaderLine('Content-Type'));
        self::assertSame('"' . $sha . '"', $response->getHeaderLine('ETag'));
        self::assertSame('3000', $response->getHeaderLine('Content-Length'));
        self::assertSame('bytes', $response->getHeaderLine('Accept-Ranges'));
        self::assertSame('private, no-cache', $response->getHeaderLine('Cache-Control'));
        self::assertSame('nosniff', $response->getHeaderLine('X-Content-Type-Options'));
        self::assertSame("default-src 'none'; sandbox", $response->getHeaderLine('Content-Security-Policy'));
        self::assertSame('attachment; filename="' . $sha . '"', $response->getHeaderLine('Content-Disposition'));
    }

    public function testAFileUploadedThroughTheApiDownloadsTheSame(): void
    {
        $bytes = random_bytes(5000);
        $sha = hash('sha256', $bytes);
        self::assertSame(200, $this->send($this->chunk($sha, $bytes, 0, 5000, $this->owner))->getStatusCode());
        $this->picture($this->workspace, null, $sha, 'image/png');

        $response = $this->send($this->get($sha, $this->owner));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('image/png', $response->getHeaderLine('Content-Type'));
        self::assertSame($bytes, (string) $response->getBody());
    }

    public function testAVoiceNoteIsAudioMp4(): void
    {
        $sha = $this->stored($this->workspace, 'Aufnahme');
        $this->note($this->workspace, null, $sha);

        $response = $this->send($this->get($sha, $this->owner));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('audio/mp4', $response->getHeaderLine('Content-Type'));
        self::assertSame('Aufnahme', (string) $response->getBody());
    }

    public function testAPictureTypeOffTheListGoesOutAsOctetStream(): void
    {
        $html = $this->stored($this->workspace, '<script>alert(1)</script>');
        $this->picture($this->workspace, null, $html, 'text/html');
        $mixed = $this->stored($this->workspace, 'zweimal');
        $this->picture($this->workspace, null, $mixed, 'image/jpeg');
        $this->picture($this->workspace, null, $mixed, 'image/png');
        $both = $this->stored($this->workspace, 'Bild und Ton');
        $this->picture($this->workspace, null, $both, 'image/webp');
        $this->note($this->workspace, null, $both);

        self::assertSame('application/octet-stream', $this->send($this->get($html, $this->owner))->getHeaderLine('Content-Type'));
        self::assertSame('application/octet-stream', $this->send($this->get($mixed, $this->owner))->getHeaderLine('Content-Type'));
        self::assertSame('image/webp', $this->send($this->get($both, $this->owner))->getHeaderLine('Content-Type'), 'the picture wins');
    }

    public function testACustomerReadsOnlyTheirOwnCustomersFiles(): void
    {
        $user = $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org');
        $customer = $this->customerOf($user);
        $token = $this->fixtures->token($this->workspace, $user)['token'];
        $own = $this->stored($this->workspace, 'eigenes Bild');
        $this->picture($this->workspace, $customer, $own);
        $ownNote = $this->stored($this->workspace, 'eigene Notiz');
        $this->note($this->workspace, $customer, $ownNote);
        $other = $this->stored($this->workspace, 'fremdes Bild');
        $this->picture($this->workspace, $this->fixtures->customer($this->workspace), $other);
        $none = $this->stored($this->workspace, 'Bild ohne Kunde');
        $this->picture($this->workspace, null, $none);

        self::assertSame('eigenes Bild', (string) $this->send($this->get($own, $token))->getBody());
        self::assertSame('eigene Notiz', (string) $this->send($this->get($ownNote, $token))->getBody());
        self::assertProblem($this->send($this->get($other, $token)), 404, 'not_found');
        self::assertProblem($this->send($this->get($none, $token)), 404, 'not_found');
        self::assertSame(200, $this->send($this->get($other, $this->owner))->getStatusCode(), 'the owner reads every customer');
    }

    public function testHelpersGet403AnonymousAndExpiredHelpers401AndOldApps426(): void
    {
        $sha = $this->stored($this->workspace, 'Kiste');
        $this->picture($this->workspace, null, $sha);
        $helper = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'helper', 'helfer@example.org'))['token'];
        $expired = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'helper', 'alt@example.org', expiresAt: '2020-01-01 00:00:00.000'))['token'];

        self::assertProblem($this->send($this->get($sha, $helper)), 403, 'forbidden');
        self::assertProblem($this->sendInvalid($this->get($sha, null), 'getFile'), 401, 'token_invalid');
        self::assertProblem($this->send($this->get($sha, $expired)), 401, 'token_invalid');

        $this->minimumAppVersion = '2.0.0';
        self::assertProblem($this->send($this->get($sha, $this->owner)->withHeader('Wio-App-Version', '1.0.0')), 426, 'upgrade_required');
    }

    public function testEveryHashTheCallerMayNotReadGetsTheSame404(): void
    {
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $answers = [];

        $answers['unknown'] = $this->send($this->get(hash('sha256', 'nichts'), $this->owner));
        $answers['file without record'] = $this->send($this->get($this->stored($this->workspace, 'lose Datei'), $this->owner));

        $partial = hash('sha256', 'halb fertig');
        $this->send($this->chunk($partial, 'halb', 0, 11, $this->owner));
        $this->picture($this->workspace, null, $partial);
        $answers['partial file'] = $this->send($this->get($partial, $this->owner));

        $missing = hash('sha256', 'nie hochgeladen');
        $this->note($this->workspace, null, $missing);
        $answers['record without file'] = $this->send($this->get($missing, $this->owner));

        $deletedPicture = $this->stored($this->workspace, 'gelöschtes Bild');
        $picture = $this->picture($this->workspace, null, $deletedPicture);
        $this->tombstone('pictures', $picture);
        $answers['deleted picture'] = $this->send($this->get($deletedPicture, $this->owner));

        $deletedNote = $this->stored($this->workspace, 'gelöschte Notiz');
        $this->tombstone('notes', $this->note($this->workspace, null, $deletedNote));
        $answers['deleted note'] = $this->send($this->get($deletedNote, $this->owner));

        $foreign = $this->stored($other, 'fremder Betrieb');
        $this->picture($other, null, $foreign);
        $answers['other workspace'] = $this->send($this->get($foreign, $this->owner));
        $this->stored($this->workspace, 'fremder Betrieb');
        $answers['other workspace record, own file'] = $this->send($this->get($foreign, $this->owner));

        $first = null;
        foreach ($answers as $case => $response) {
            self::assertProblem($response, 404, 'not_found');
            $body = (string) $response->getBody();
            $first ??= $body;
            self::assertSame($first, $body, $case);
            self::assertSame('', $response->getHeaderLine('ETag'), $case);
        }

        $this->sql->run('UPDATE pictures SET deleted_at = NULL WHERE id = ?', [$picture]);
        self::assertSame(200, $this->send($this->get($deletedPicture, $this->owner))->getStatusCode(), 'a restored picture downloads again');
    }

    public function testAMalformedHashIs400(): void
    {
        foreach ([strtoupper(hash('sha256', 'a')), substr(hash('sha256', 'a'), 1)] as $bad) {
            self::assertProblem($this->sendInvalid($this->get($bad, $this->owner), 'getFile'), 400, 'invalid_request');
        }
    }

    public function testIfNoneMatchAnswers304OnlyInsideTheScope(): void
    {
        $sha = $this->stored($this->workspace, 'gleich');
        $this->picture($this->workspace, null, $sha);
        $etag = '"' . $sha . '"';

        foreach ([$etag, '*', 'W/' . $etag, '"anders", ' . $etag] as $header) {
            $response = $this->send($this->get($sha, $this->owner)->withHeader('If-None-Match', $header));
            self::assertSame(304, $response->getStatusCode(), $header);
            self::assertSame('', (string) $response->getBody());
            self::assertSame($etag, $response->getHeaderLine('ETag'));
        }
        self::assertSame(200, $this->send($this->get($sha, $this->owner)->withHeader('If-None-Match', '"anders"'))->getStatusCode());

        $customer = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org'))['token'];
        self::assertProblem($this->send($this->get($sha, $customer)->withHeader('If-None-Match', '*')), 404, 'not_found');
    }

    public function testOneRangeIs206(): void
    {
        $bytes = '0123456789';
        $sha = $this->stored($this->workspace, $bytes);
        $this->picture($this->workspace, null, $sha);

        foreach ([
            'bytes=0-3' => ['0123', '0-3'],
            'bytes=4-' => ['456789', '4-9'],
            'bytes=-2' => ['89', '8-9'],
            'bytes=-20' => [$bytes, '0-9'],
            'bytes=7-100' => ['789', '7-9'],
            'bytes=9-9' => ['9', '9-9'],
            'BYTES = 1-2' => ['12', '1-2'],
        ] as $header => [$body, $range]) {
            $response = $this->send($this->get($sha, $this->owner)->withHeader('Range', $header));
            self::assertSame(206, $response->getStatusCode(), $header);
            self::assertSame($body, (string) $response->getBody(), $header);
            self::assertSame("bytes {$range}/10", $response->getHeaderLine('Content-Range'), $header);
            self::assertSame((string) \strlen($body), $response->getHeaderLine('Content-Length'), $header);
            self::assertSame('image/jpeg', $response->getHeaderLine('Content-Type'), $header);
            self::assertSame('nosniff', $response->getHeaderLine('X-Content-Type-Options'), $header);
        }
    }

    public function testAnUnsatisfiableRangeIs416AndOthersGetTheWholeFile(): void
    {
        $sha = $this->stored($this->workspace, '0123456789');
        $this->picture($this->workspace, null, $sha);

        foreach (['bytes=10-', 'bytes=10-20', 'bytes=-0'] as $header) {
            $response = $this->send($this->get($sha, $this->owner)->withHeader('Range', $header));
            self::assertProblem($response, 416, 'range_not_satisfiable');
            self::assertSame('bytes */10', $response->getHeaderLine('Content-Range'), $header);
        }
        foreach (['bytes=0-1,4-5', 'bytes=5-2', 'items=0-1', 'bytes=-', 'bytes=a-b', 'bytes=0-1 ,'] as $header) {
            $response = $this->send($this->get($sha, $this->owner)->withHeader('Range', $header));
            self::assertSame(200, $response->getStatusCode(), $header);
            self::assertSame('0123456789', (string) $response->getBody(), $header);
        }

        $customer = $this->fixtures->token($this->workspace, $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org'))['token'];
        self::assertProblem($this->send($this->get($sha, $customer)->withHeader('Range', 'bytes=10-')), 404, 'not_found');
    }

    /**
     * Plan 079 T1 and T2 (D-355): a resume past the end, with a matching
     * If-Range, still gets the file size, and a web origin may read it.
     */
    public function testA416ToAResumeCarriesTheSizeAndTheWebMayReadIt(): void
    {
        $this->corsOrigins = 'https://app.example.org';
        $sha = $this->stored($this->workspace, '0123456789');
        $this->picture($this->workspace, null, $sha);

        $response = $this->send(
            $this->get($sha, $this->owner)
                ->withHeader('Range', 'bytes=10-4194313')
                ->withHeader('If-Range', '"' . $sha . '"')
                ->withHeader('Origin', 'https://app.example.org'),
        );

        self::assertProblem($response, 416, 'range_not_satisfiable');
        self::assertSame('bytes */10', $response->getHeaderLine('Content-Range'));
        self::assertSame('https://app.example.org', $response->getHeaderLine('Access-Control-Allow-Origin'));
        self::assertContains('Content-Range', array_map('trim', explode(',', $response->getHeaderLine('Access-Control-Expose-Headers'))));
    }

    public function testIfRangeSendsTheRangeOnlyForTheSameFile(): void
    {
        $sha = $this->stored($this->workspace, '0123456789');
        $this->picture($this->workspace, null, $sha);

        $same = $this->send($this->get($sha, $this->owner)->withHeader('Range', 'bytes=2-3')->withHeader('If-Range', '"' . $sha . '"'));
        self::assertSame(206, $same->getStatusCode());
        self::assertSame('23', (string) $same->getBody());

        foreach (['"' . hash('sha256', 'anders') . '"', 'W/"' . $sha . '"', 'Wed, 18 Nov 2026 09:00:00 GMT'] as $header) {
            $whole = $this->send($this->get($sha, $this->owner)->withHeader('Range', 'bytes=2-3')->withHeader('If-Range', $header));
            self::assertSame(200, $whole->getStatusCode(), $header);
            self::assertSame('0123456789', (string) $whole->getBody(), $header);
        }
    }

    public function testALargeFileStreamsWithoutLoadingItIntoMemory(): void
    {
        $size = 12 * 1048576;
        $sha = $this->storedLarge($this->workspace, $size);
        $this->picture($this->workspace, null, $sha);
        $app = $this->app();
        $request = $this->get($sha, $this->owner);

        gc_collect_cycles();
        $before = memory_get_usage();
        memory_reset_peak_usage();
        $response = $app->handle($request);
        self::assertSame(200, $response->getStatusCode());
        $body = $response->getBody();
        $hash = hash_init('sha256');
        $received = 0;
        while (!$body->eof()) {
            $piece = $body->read(4096); // Slim's emitter reads in pieces of this size.
            hash_update($hash, $piece);
            $received += \strlen($piece);
        }
        $growth = memory_get_peak_usage() - $before;

        self::assertSame($size, $received);
        self::assertSame($sha, hash_final($hash));
        self::assertLessThan(2 * 1048576, $growth, 'peak memory grew by ' . $growth . ' bytes');

        $tail = $app->handle($this->get($sha, $this->owner)->withHeader('Range', 'bytes=' . ($size - 4096) . '-'));
        self::assertSame(206, $tail->getStatusCode());
        self::assertSame(4096, \strlen((string) $tail->getBody()));
    }

    private function get(string $sha256, ?string $token): ServerRequestInterface
    {
        return $this->call('GET', '/files/' . $sha256, token: $token);
    }

    /**
     * Puts a complete file into a workspace's store, as an upload leaves it.
     */
    private function stored(string $workspace, string $bytes): string
    {
        $sha = hash('sha256', $bytes);
        $dir = $this->filesDir . '/' . $workspace;
        if (!is_dir($dir)) {
            mkdir($dir, 0o700, true);
        }
        file_put_contents($dir . '/' . $sha, $bytes);

        return $sha;
    }

    private function storedLarge(string $workspace, int $size): string
    {
        $dir = $this->filesDir . '/' . $workspace;
        mkdir($dir, 0o700, true);
        $path = $dir . '/upload';
        $handle = fopen($path, 'wb');
        self::assertNotFalse($handle);
        $hash = hash_init('sha256');
        for ($written = 0; $written < $size; $written += 1048576) {
            $piece = random_bytes(1048576);
            fwrite($handle, $piece);
            hash_update($hash, $piece);
        }
        fclose($handle);
        $sha = hash_final($hash);
        rename($path, $dir . '/' . $sha);

        return $sha;
    }

    private function picture(string $workspace, ?string $customer, string $sha256, string $mime = 'image/jpeg'): string
    {
        return $this->rows->picture($workspace, $customer, ['file_sha256' => $sha256, 'file_mime' => $mime]);
    }

    private function note(string $workspace, ?string $customer, string $sha256): string
    {
        return $this->rows->insert('notes', [
            'workspace_id' => $workspace,
            'customer_id' => $customer,
            'subject_type' => 'customer',
            'subject_id' => $customer ?? Rows::uuid(),
            'audio_sha256' => $sha256,
            'audio_bytes' => 100,
            'audio_seconds' => 3,
        ]);
    }

    private function tombstone(string $table, string $id): void
    {
        $this->sql->run('UPDATE `' . $table . '` SET deleted_at = UTC_TIMESTAMP(3) WHERE id = ?', [$id]);
    }

    private function customerOf(string $userId): string
    {
        $row = $this->sql->row('SELECT customer_id FROM users WHERE id = ?', [$userId]);
        self::assertIsString($row['customer_id'] ?? null);

        return $row['customer_id'];
    }
}
