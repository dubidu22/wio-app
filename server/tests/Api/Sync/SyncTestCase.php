<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Psr\Http\Message\ResponseInterface;
use Wio\Support\Uuid;
use Wio\Tests\Api\DatabaseTestCase;

/**
 * Sync tests: an owner of a professional workspace, and helpers to push and
 * pull through the API, each request and answer checked against the
 * contract. Every value is invented (example.org, postal code 00000).
 */
abstract class SyncTestCase extends DatabaseTestCase
{
    protected const string SHA = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

    protected string $workspace;

    protected string $owner;

    protected string $ownerToken;

    /** The same owner on a second device. */
    protected string $secondToken;

    protected function setUp(): void
    {
        parent::setUp();
        $this->workspace = $this->fixtures->workspace();
        $this->owner = $this->fixtures->user($this->workspace);
        $this->ownerToken = $this->fixtures->token($this->workspace, $this->owner)['token'];
        $this->secondToken = $this->fixtures->token($this->workspace, $this->owner, 'Zweitgerät')['token'];
    }

    protected static function id(): string
    {
        return Uuid::v7(new \DateTimeImmutable());
    }

    /**
     * One outbox entry.
     *
     * @param array<string, mixed> $fields
     *
     * @return array<string, mixed>
     */
    protected static function change(string $entity, string $id, string $op = 'upsert', array $fields = [], ?int $base = null, ?string $changeId = null, string $deviceTime = '2026-11-18T09:00:00.000Z'): array
    {
        return [
            'change_id' => $changeId ?? self::id(),
            'entity' => $entity,
            'id' => $id,
            'op' => $op,
            'fields' => (object) $fields,
            'base_revision' => $base,
            'device_time' => $deviceTime,
        ];
    }

    /**
     * @param list<array<string, mixed>> $changes
     */
    protected function pushResponse(array $changes, ?string $token = null): ResponseInterface
    {
        return $this->send($this->call('POST', '/sync/push', ['changes' => $changes], token: $token ?? $this->ownerToken));
    }

    /**
     * @param list<array<string, mixed>> $changes
     *
     * @return list<array<string, mixed>>
     */
    protected function push(array $changes, ?string $token = null): array
    {
        $response = $this->pushResponse($changes, $token);
        self::assertSame(200, $response->getStatusCode(), (string) $response->getBody());
        $results = self::json($response)['results'] ?? null;
        self::assertIsArray($results);
        self::assertCount(\count($changes), $results);
        $out = [];
        foreach ($results as $i => $result) {
            self::assertIsArray($result);
            self::assertSame($changes[$i]['change_id'], $result['change_id'], 'results come back in request order');
            $out[] = self::fields($result);
        }

        return $out;
    }

    /**
     * Pushes one change the contract itself does not allow (an op outside
     * its enum, as a newer app might send): the server still answers it per
     * change.
     *
     * @param array<string, mixed> $change
     *
     * @return array<string, mixed>
     */
    protected function pushOutsideSchema(array $change): array
    {
        $response = $this->sendInvalid($this->call('POST', '/sync/push', ['changes' => [$change]], token: $this->ownerToken), 'syncPush');
        self::assertSame(200, $response->getStatusCode(), (string) $response->getBody());
        $results = self::json($response)['results'] ?? null;
        self::assertIsArray($results);

        return self::fields($results[0] ?? null);
    }

    /**
     * @param array<string, mixed> $change
     *
     * @return array<string, mixed>
     */
    protected function pushOne(array $change, ?string $token = null): array
    {
        return $this->push([$change], $token)[0];
    }

    /**
     * Pushes one change and returns its new revision; fails unless it was applied or merged.
     *
     * @param array<string, mixed> $fields
     */
    protected function write(string $entity, string $id, array $fields = [], string $op = 'upsert', ?int $base = null, ?string $token = null): int
    {
        $result = $this->pushOne(self::change($entity, $id, $op, $fields, $base), $token);
        self::assertContains($result['status'], ['applied', 'merged'], "{$op} {$entity}: " . json_encode($result));
        self::assertIsInt($result['revision']);

        return $result['revision'];
    }

    /**
     * @param array<string, mixed> $result
     */
    protected static function assertRejected(string $reason, array $result, string $message = ''): void
    {
        self::assertSame('rejected', $result['status'], $message . ' ' . json_encode($result));
        self::assertSame($reason, $result['reason'] ?? null, $message . ' ' . json_encode($result));
        self::assertArrayNotHasKey('revision', $result);
    }

    /**
     * One page, with its records typed for the tests.
     *
     * @return array{records: list<array{entity: string, id: string, revision: int, deleted_at: ?string, fields: array<string, mixed>}>, has_more: bool, last_revision: int}
     */
    protected function pull(int $since = 0, ?int $limit = null, ?string $token = null): array
    {
        $query = 'since=' . $since . ($limit === null ? '' : '&limit=' . $limit);
        $response = $this->send($this->call('GET', '/sync/pull?' . $query, token: $token ?? $this->ownerToken));
        self::assertSame(200, $response->getStatusCode(), (string) $response->getBody());
        $body = self::json($response);
        self::assertIsArray($body['records']);
        self::assertIsBool($body['has_more']);
        self::assertIsInt($body['last_revision']);
        $records = [];
        foreach ($body['records'] as $record) {
            self::assertIsArray($record);
            $records[] = [
                'entity' => self::str($record['entity'] ?? null),
                'id' => self::str($record['id'] ?? null),
                'revision' => self::int($record['revision'] ?? null),
                'deleted_at' => $record['deleted_at'] === null ? null : self::str($record['deleted_at']),
                'fields' => self::fields($record['fields'] ?? null),
            ];
        }

        return ['records' => $records, 'has_more' => $body['has_more'], 'last_revision' => $body['last_revision']];
    }

    /**
     * Pulls every page from $since and returns the records and the stored revision.
     *
     * @return array{list<array{entity: string, id: string, revision: int, deleted_at: ?string, fields: array<string, mixed>}>, int}
     */
    protected function pullAll(int $since = 0, ?string $token = null, ?int $limit = null): array
    {
        $records = [];
        for ($pages = 0; $pages < 1000; ++$pages) {
            $page = $this->pull($since, $limit, $token);
            array_push($records, ...$page['records']);
            if (!$page['has_more']) {
                return [$records, $page['last_revision']];
            }
            self::assertGreaterThan($since, $page['last_revision'], 'last_revision moves on while has_more is true');
            $since = $page['last_revision'];
        }
        self::fail('Pull never ended.');
    }

    /**
     * The newest pulled state of one record, or null.
     *
     * @return array<string, mixed>|null
     */
    protected function pulled(string $entity, string $id, ?string $token = null): ?array
    {
        $found = null;
        foreach ($this->pullAll(0, $token)[0] as $record) {
            if ($record['entity'] === $entity && $record['id'] === $id) {
                $found = $record['fields'];
            }
        }

        return $found;
    }

    protected static function str(mixed $value): string
    {
        self::assertIsString($value);

        return $value;
    }

    protected static function int(mixed $value): int
    {
        self::assertIsInt($value);

        return $value;
    }

    /**
     * @return array<string, mixed>
     */
    protected static function fields(mixed $value): array
    {
        self::assertIsArray($value);
        $out = [];
        foreach ($value as $key => $item) {
            $out[(string) $key] = $item;
        }

        return $out;
    }

    /**
     * A customer with one record of every entity, made through push by the
     * owner (personal workspaces leave customer_id null; this one is
     * professional).
     *
     * @return array<string, string> entity => id
     */
    protected function graph(string $code = 'WIO-0001', ?string $customer = null): array
    {
        $ids = [];
        if ($customer === null) {
            $customer = self::id();
            $this->write('customers', $customer, ['name' => 'Familie Beispiel', 'contact' => ['email' => 'familie@example.org'], 'external_ref' => 'K-' . $code]);
        }
        $ids['customers'] = $customer;
        $create = function (string $entity, array $fields) use (&$ids): void {
            $ids[$entity] = self::id();
            $this->write($entity, $ids[$entity], $fields);
        };
        $create('sites', ['customer_id' => $customer, 'name' => 'Altbau', 'address' => 'Musterweg 1, 00000 Beispielstadt']);
        $create('rooms', ['site_id' => $ids['sites'], 'name' => 'Küche', 'outline' => [['x_cm' => 0, 'y_cm' => 0], ['x_cm' => 400, 'y_cm' => 0], ['x_cm' => 400, 'y_cm' => 300]], 'height_cm' => 250]);
        $create('openings', ['room_id' => $ids['rooms'], 'kind' => 'door', 'wall_index' => 0, 'offset_cm' => 20, 'width_cm' => 80]);
        $create('fixtures', ['room_id' => $ids['rooms'], 'name' => 'Regal', 'levels' => [['height_cm' => 40, 'compartments' => 2]]]);
        $create('entries', ['customer_id' => $customer, 'code' => $code, 'title' => 'Karton Bücher']);
        $create('pictures', ['entry_id' => $ids['entries'], 'file_sha256' => self::SHA, 'file_bytes' => 1000, 'file_mime' => 'image/jpeg', 'width_px' => 640, 'height_px' => 480]);
        $create('notes', ['subject_type' => 'entry', 'subject_id' => $ids['entries'], 'text' => 'Vorsicht, schwer']);
        $create('labels', ['name' => 'Zerbrechlich ' . $code]);
        $create('property_keys', ['name' => 'Gewicht ' . $code, 'unit' => 'kg']);
        $create('entity_labels', ['entity_type' => 'entry', 'entity_id' => $ids['entries'], 'label_id' => $ids['labels']]);
        $create('entity_properties', ['entity_type' => 'entry', 'entity_id' => $ids['entries'], 'key_id' => $ids['property_keys'], 'value_number' => '12.5']);
        $create('jobs', ['customer_id' => $customer, 'date' => '2026-11-20', 'agreed_minutes' => 240]);
        $create('time_blocks', ['job_id' => $ids['jobs'], 'started_at' => '2026-11-20T08:00:00.000Z']);
        $create('sign_offs', ['job_id' => $ids['jobs'], 'minutes_confirmed' => 240, 'signature' => [[0, 0], [10, 12]], 'signed_at' => '2026-11-20T16:00:00.000Z']);
        $create('expenses', ['job_id' => $ids['jobs'], 'picture_id' => $ids['pictures'], 'amount_cents' => 1250, 'note' => 'Klebeband']);

        return $ids;
    }
}
