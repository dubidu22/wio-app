<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

/**
 * A phone for the sync property tests (plan 006, P5 and P6), doing what the
 * KB asks of the app (sync.md): write locally, append to an outbox, push at
 * most 200 changes, remove a change only when its change_id comes back
 * applied or merged, pull until has_more is false. The network may lose a
 * request or an answer; the random source is seeded, so a failing run can be
 * repeated.
 */
final class SimulatedDevice
{
    /** @var list<array<string, mixed>> */
    public array $outbox = [];

    /** @var array<string, array<string, mixed>> "entity id" => pulled fields */
    public array $local = [];

    /** @var array<string, int> "entity id" => revision last pulled */
    public array $revisions = [];

    /** @var array<string, array<string, mixed>> change_id => the server's answer, once received */
    public array $answers = [];

    /** @var array<string, array<string, mixed>> change_id => the change, for every change ever made */
    public array $made = [];

    public int $since = 0;

    /**
     * @param \Closure(list<array<string, mixed>>): list<array<string, mixed>> $push
     * @param \Closure(int): array{records: list<array{entity: string, id: string, revision: int, deleted_at: ?string, fields: array<string, mixed>}>, has_more: bool, last_revision: int} $pull
     * @param \Closure(): string $uuid
     * @param \Closure(int, int): int $random
     */
    public function __construct(
        private readonly \Closure $push,
        private readonly \Closure $pull,
        private readonly \Closure $uuid,
        private readonly \Closure $random,
    ) {}

    /**
     * @param array<string, mixed> $fields
     */
    public function change(string $entity, string $id, string $op = 'upsert', array $fields = []): void
    {
        $key = "{$entity} {$id}";
        $changeId = ($this->uuid)();
        $change = [
            'change_id' => $changeId,
            'entity' => $entity,
            'id' => $id,
            'op' => $op,
            'fields' => (object) $fields,
            'base_revision' => $this->revisions[$key] ?? null,
            // A wrong device clock (P4) must not matter.
            'device_time' => sprintf('20%02d-0%d-1%dT0%d:00:00.000Z', ($this->random)(19, 35), ($this->random)(1, 9), ($this->random)(0, 9), ($this->random)(0, 9)),
        ];
        $this->outbox[] = $change;
        $this->made[$changeId] = $change;
    }

    /**
     * One push of up to 200 changes. $loss: 0 delivered, 1 the request is
     * lost, 2 the answer is lost.
     */
    public function pushOnce(int $loss = 0): void
    {
        $page = \array_slice($this->outbox, 0, 200);
        if ($page === [] || $loss === 1) {
            return;
        }
        $results = ($this->push)($page);
        if ($loss === 2) {
            return;
        }
        $done = [];
        foreach ($results as $result) {
            $changeId = \is_string($result['change_id'] ?? null) ? $result['change_id'] : '';
            $this->answers[$changeId] = $result;
            // Rejected changes leave the outbox too: the app shows them in a list (D-189).
            $done[$changeId] = true;
        }
        $this->outbox = array_values(array_filter($this->outbox, static fn(array $c): bool => !\is_string($c['change_id']) || !isset($done[$c['change_id']])));
    }

    /**
     * Pulls every page; a lost answer leaves `since` where it was.
     */
    public function pullAll(int $loss = 0): void
    {
        for ($pages = 0; $pages < 1000; ++$pages) {
            $page = ($this->pull)($this->since);
            if ($loss === 2) {
                return;
            }
            foreach ($page['records'] as $record) {
                $key = $record['entity'] . ' ' . $record['id'];
                $this->local[$key] = $record['fields'];
                $this->revisions[$key] = $record['revision'];
            }
            $this->since = $page['last_revision'];
            if (!$page['has_more']) {
                return;
            }
        }
        throw new \RuntimeException('Pull never ended.');
    }

    /**
     * Pushes until the outbox is empty, without loss.
     */
    public function drain(): void
    {
        for ($i = 0; $this->outbox !== [] && $i < 1000; ++$i) {
            $this->pushOnce();
        }
    }
}
