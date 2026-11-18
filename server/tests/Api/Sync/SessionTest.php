<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use PHPUnit\Framework\Attributes\DataProvider;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 tests P5 and P6, the M1 tests of KB sync.md:
 *
 * - P5: a push of 1,000 and of 5,000 changes in one session, in pages of
 *   200, with lost requests and lost answers. Every change gets exactly one
 *   answer, nothing is lost, revisions are gap-free.
 * - P6: two devices, random edits, random loss. After a final push and pull
 *   both equal the server, and every confirmed change is in the server's
 *   state unless a later one replaced it.
 *
 * The random source is seeded: CI uses fixed seeds, a local run a random one
 * (or WIO_SYNC_SEED). Every assertion message carries the seed, so a failure
 * can be repeated with WIO_SYNC_SEED=<seed>.
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class SessionTest extends SyncTestCase
{
    private int $seed = 0;

    /**
     * @return iterable<string, array{int}>
     */
    public static function sessions(): iterable
    {
        yield '1,000 changes' => [1000];
        yield '5,000 changes' => [5000];
    }

    #[DataProvider('sessions')]
    public function testAPushSessionLosesNothing(int $count): void
    {
        $this->seed(1);
        $device = $this->device($this->ownerToken);
        $labels = [];
        for ($i = 0; $i < $count; ++$i) {
            // Mostly new labels, some edits of labels made earlier in the session.
            if ($labels !== [] && mt_rand(1, 5) === 1) {
                $device->change('labels', $labels[mt_rand(0, \count($labels) - 1)], fields: ['name' => "Label {$i}"]);
            } else {
                $labels[] = $id = $this->uuid();
                $device->change('labels', $id, fields: ['name' => "Label {$i}"]);
            }
        }

        for ($round = 0; $device->outbox !== [] && $round < 1000; ++$round) {
            $device->pushOnce(mt_rand(1, 10) <= 2 ? mt_rand(1, 2) : 0);
        }

        self::assertSame([], $device->outbox, $this->seedNote());
        self::assertCount($count, $device->answers, 'one answer per change ' . $this->seedNote());
        foreach ($device->answers as $answer) {
            self::assertContains($answer['status'], ['applied', 'merged'], json_encode($answer) . $this->seedNote());
        }
        self::assertSame($count, $this->fixtures->count('applied_changes'), 'every change applied once ' . $this->seedNote());
        self::assertSame(\count($labels), $this->fixtures->count('labels'), $this->seedNote());
        [$records, $top] = $this->pullAll();
        self::assertSame(2 + $count, $top, 'one revision per change ' . $this->seedNote());
        $revisions = array_map(static fn(array $r): int => $r['revision'], $records);
        sort($revisions);
        self::assertSame($revisions, array_values(array_unique($revisions)), $this->seedNote());
    }

    public function testTwoDevicesConvergeAndNoConfirmedChangeIsLost(): void
    {
        $seed = getenv('WIO_SYNC_SEED');
        $this->seed(is_numeric($seed) ? (int) $seed : (getenv('CI') !== false ? 6 : random_int(1, 1_000_000)));
        $devices = [$this->device($this->ownerToken), $this->device($this->secondToken)];

        for ($step = 0; $step < 400; ++$step) {
            $device = $devices[mt_rand(0, 1)];
            $this->randomEdit($device);
            $roll = mt_rand(1, 10);
            if ($roll <= 3) {
                $device->pushOnce(mt_rand(1, 10) <= 3 ? mt_rand(1, 2) : 0);
            } elseif ($roll <= 5) {
                $device->pullAll(mt_rand(1, 10) <= 2 ? 2 : 0);
            }
        }
        foreach ($devices as $device) {
            $device->drain();
        }
        foreach ($devices as $device) {
            $device->pullAll();
        }

        $server = [];
        foreach ($this->pullAll()[0] as $record) {
            if (\in_array($record['entity'], ['sites', 'rooms'], true)) {
                $server[$record['entity'] . ' ' . $record['id']] = $record['fields'];
            }
        }
        foreach ($devices as $i => $device) {
            $local = array_filter($device->local, static fn(string $key): bool => str_starts_with($key, 'sites ') || str_starts_with($key, 'rooms '), ARRAY_FILTER_USE_KEY);
            ksort($local);
            ksort($server);
            self::assertEquals($server, $local, "device {$i} equals the server " . $this->seedNote());
        }
        $this->assertNoConfirmedChangeIsLost($devices, $server);
    }

    /**
     * For every field, the server holds the value of the applied or merged
     * change with the highest revision that wrote it; the same for deletes.
     *
     * @param list<SimulatedDevice> $devices
     * @param array<string, array<string, mixed>> $server
     */
    private function assertNoConfirmedChangeIsLost(array $devices, array $server): void
    {
        $expected = [];
        $confirmed = 0;
        foreach ($devices as $device) {
            foreach ($device->made as $changeId => $change) {
                $answer = $device->answers[$changeId] ?? null;
                self::assertNotNull($answer, 'every change got an answer ' . $this->seedNote());
                if (!\in_array($answer['status'], ['applied', 'merged'], true)) {
                    self::assertSame('deleted', $answer['reason'] ?? null, 'only edits of deleted records are refused ' . json_encode($answer) . $this->seedNote());
                    continue;
                }
                ++$confirmed;
                $key = self::str($change['entity']) . ' ' . self::str($change['id']);
                $revision = self::int($answer['revision']);
                $writes = $change['op'] === 'upsert' ? (array) $change['fields'] : ['deleted' => $change['op'] === 'delete'];
                foreach ($writes as $field => $value) {
                    if (($expected[$key][$field][0] ?? -1) <= $revision) {
                        $expected[$key][$field] = [$revision, $value];
                    }
                }
            }
        }
        self::assertGreaterThan(100, $confirmed, $this->seedNote());
        foreach ($expected as $key => $fields) {
            self::assertArrayHasKey($key, $server, $this->seedNote());
            foreach ($fields as $field => [$revision, $value]) {
                $actual = $field === 'deleted' ? $server[$key]['deleted_at'] !== null : $server[$key][$field];
                self::assertSame($value, $actual, "{$key}.{$field} holds the change of revision {$revision} " . $this->seedNote());
            }
        }
    }

    private function randomEdit(SimulatedDevice $device): void
    {
        $sites = $this->known($device, 'sites');
        $rooms = $this->known($device, 'rooms');
        $roll = mt_rand(1, 12);
        if ($sites === [] || $roll === 1) {
            $device->change('sites', $this->uuid(), fields: ['name' => $this->word(), 'address' => $this->word()]);
        } elseif ($roll <= 5) {
            $field = mt_rand(0, 1) === 0 ? 'name' : 'address';
            $device->change('sites', $sites[mt_rand(0, \count($sites) - 1)], fields: [$field => $this->word()]);
        } elseif ($roll === 6) {
            $device->change('sites', $sites[mt_rand(0, \count($sites) - 1)], mt_rand(0, 1) === 0 ? 'delete' : 'restore');
        } elseif ($rooms === [] || $roll === 7) {
            $device->change('rooms', $this->uuid(), fields: ['site_id' => $sites[mt_rand(0, \count($sites) - 1)], 'name' => $this->word()]);
        } elseif ($roll <= 11) {
            $fields = mt_rand(0, 1) === 0 ? ['name' => $this->word()] : ['height_cm' => mt_rand(200, 300), 'name' => $this->word()];
            $device->change('rooms', $rooms[mt_rand(0, \count($rooms) - 1)], fields: $fields);
        } else {
            $device->change('rooms', $rooms[mt_rand(0, \count($rooms) - 1)], mt_rand(0, 1) === 0 ? 'delete' : 'restore');
        }
    }

    /**
     * Ids the device knows: pulled, or made by its own outbox.
     *
     * @return list<string>
     */
    private function known(SimulatedDevice $device, string $entity): array
    {
        $ids = [];
        foreach (array_keys($device->local) as $key) {
            if (str_starts_with($key, "{$entity} ")) {
                $ids[substr($key, \strlen($entity) + 1)] = true;
            }
        }
        foreach ($device->made as $change) {
            if ($change['entity'] === $entity && $change['op'] === 'upsert' && $change['base_revision'] === null) {
                $ids[self::str($change['id'])] = true;
            }
        }
        $ids = array_keys($ids);
        sort($ids);

        return array_map('strval', $ids);
    }

    private function device(string $token): SimulatedDevice
    {
        return new SimulatedDevice(
            fn(array $changes): array => $this->push($changes, $token),
            fn(int $since): array => $this->pull($since, null, $token),
            $this->uuid(...),
            static fn(int $min, int $max): int => mt_rand($min, $max),
        );
    }

    private function seed(int $seed): void
    {
        $this->seed = $seed;
        mt_srand($seed);
    }

    private function seedNote(): string
    {
        return "(seed {$this->seed}; repeat with WIO_SYNC_SEED={$this->seed})";
    }

    private function uuid(): string
    {
        $hex = '';
        for ($i = 0; $i < 8; ++$i) {
            $hex .= sprintf('%04x', mt_rand(0, 0xFFFF));
        }

        return sprintf('%s-%s-7%s-8%s-%s', substr($hex, 0, 8), substr($hex, 8, 4), substr($hex, 13, 3), substr($hex, 17, 3), substr($hex, 20, 12));
    }

    private function word(): string
    {
        return ['Keller', 'Küche', 'Bad', 'Flur', 'Garage', 'Dachboden', 'Büro', 'Altbau'][mt_rand(0, 7)] . ' ' . mt_rand(1, 99);
    }
}
