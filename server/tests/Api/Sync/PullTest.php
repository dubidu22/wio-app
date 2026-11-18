<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Wio\Database\Connection;
use Wio\Schema\RevisionCounter;
use Wio\Tests\Api\Contract\RecordFields;
use Wio\Tests\Api\Operation;

/**
 * Plan 006 tests P12 (paging and scope, D-182, D-183), P13 (410, D-184) and
 * P14 (a pull during a write sees only committed, gap-free revisions).
 */
#[Operation('syncPush')]
#[Operation('syncPull')]
final class PullTest extends SyncTestCase
{
    public function testPagesOf500InRevisionOrderUntilHasMoreIsFalse(): void
    {
        for ($page = 0; $page < 6; ++$page) {
            $changes = [];
            for ($i = 0; $i < 200; ++$i) {
                $changes[] = self::change('labels', self::id(), fields: ['name' => "Label {$page}-{$i}"]);
            }
            $this->push($changes);
        }

        $first = $this->pull();
        self::assertCount(500, $first['records']);
        self::assertTrue($first['has_more']);
        $second = $this->pull($first['last_revision']);
        $third = $this->pull($second['last_revision']);

        self::assertCount(500, $second['records']);
        self::assertTrue($second['has_more']);
        self::assertFalse($third['has_more']);
        // The workspace row, the owner and 1,200 labels.
        self::assertCount(1202 - 1000, $third['records']);
        $revisions = array_map(static fn(array $r): int => $r['revision'], [...$first['records'], ...$second['records'], ...$third['records']]);
        self::assertSame(range(1, 1202), $revisions, 'every revision once, in order');
        self::assertSame(1202, $third['last_revision']);
        self::assertSame(['records' => [], 'has_more' => false, 'last_revision' => 1202], $this->pull(1202));
    }

    public function testTheDefaultLimitIs500AndALimitIsRespected(): void
    {
        $this->push(array_map(static fn(int $i): array => self::change('labels', self::id(), fields: ['name' => "L{$i}"]), range(1, 10)));

        $page = $this->pull(0, 3);

        self::assertCount(3, $page['records']);
        self::assertTrue($page['has_more']);
        self::assertSame(3, $page['last_revision']);
        self::assertCount(12, $this->pull()['records']);
    }

    public function testACustomerPullsOnlyTheirCustomerAndTheVocabulary(): void
    {
        $mine = $this->graph();
        $theirs = $this->graph('WIO-0002');
        $this->write('entries', $mine['entries'], ['site_id' => $mine['sites'], 'room_id' => $mine['rooms']], 'move_entry');
        // A conflict on a record of this very customer: still the owner's only.
        $this->pushOne(self::change('entries', $mine['entries'], fields: ['title' => 'Streit']), $this->secondToken);
        self::assertSame($mine['customers'], $this->sql->row('SELECT customer_id FROM conflicts')['customer_id'] ?? null);
        $customer = $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org', customerId: $mine['customers']);
        $this->fixtures->user($this->workspace, 'customer', 'andere@example.org', customerId: $theirs['customers']);
        $token = $this->fixtures->token($this->workspace, $customer)['token'];

        [$records, $last] = $this->pullAll(0, $token, 7);

        $seen = [];
        foreach ($records as $record) {
            RecordFields::checkPulled($record['entity'], $record['fields']);
            self::assertArrayNotHasKey('email_key', $record['fields']);
            $seen[$record['entity'] . ' ' . $record['id']] = $record['fields'];
        }
        $expected = ['workspaces ' . $this->workspace, 'users ' . $customer, 'labels ' . $mine['labels'], 'labels ' . $theirs['labels'], 'property_keys ' . $mine['property_keys'], 'property_keys ' . $theirs['property_keys']];
        foreach ($mine as $entity => $id) {
            $expected[] = "{$entity} {$id}";
        }
        $expected[] = 'place_history ' . self::str($this->sql->row('SELECT id FROM place_history')['id'] ?? null);
        sort($expected);
        $actual = array_keys($seen);
        sort($actual);
        self::assertSame(array_values(array_unique($expected)), $actual);
        self::assertSame('kunde@example.org', $seen['users ' . $customer]['email']);
        [, $top] = $this->pullAll();
        self::assertSame($top, $last, 'last_revision reaches the counter past the records the customer may not read');
    }

    public function testAHelperPullsOnlyTheWorkspaceAndThemselvesUntilM6(): void
    {
        $ids = $this->graph();
        $helper = $this->fixtures->user($this->workspace, 'helper', 'helfer@example.org', customerId: $ids['customers']);
        $token = $this->fixtures->token($this->workspace, $helper)['token'];

        [$records] = $this->pullAll(0, $token, 1);

        self::assertSame([['workspaces', $this->workspace], ['users', $helper]], array_map(static fn(array $r): array => [$r['entity'], $r['id']], $records));
    }

    public function testOwnersSeeEveryUsersEmailButNeverTheEmailKey(): void
    {
        $ids = $this->graph();
        $customer = $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org', customerId: $ids['customers']);

        $users = array_values(array_filter($this->pullAll()[0], static fn(array $r): bool => $r['entity'] === 'users'));

        self::assertCount(2, $users);
        foreach ($users as $user) {
            self::assertArrayNotHasKey('email_key', $user['fields']);
            self::assertArrayNotHasKey('alive', $user['fields']);
        }
        self::assertSame(['inhaber@example.org', 'kunde@example.org'], [$users[0]['fields']['email'], $users[1]['fields']['email']]);
        self::assertSame($customer, $users[1]['id']);
    }

    public function testTombstonesArePulledAsFullRecords(): void
    {
        $label = self::id();
        $this->write('labels', $label, ['name' => 'Keller']);
        $this->write('labels', $label, op: 'delete');

        $record = array_values(array_filter($this->pullAll()[0], static fn(array $r): bool => $r['id'] === $label))[0];

        self::assertSame('2026-11-18T10:00:00.000Z', $record['deleted_at']);
        self::assertSame('Keller', $record['fields']['name']);
        self::assertSame($record['deleted_at'], $record['fields']['deleted_at']);
    }

    public function testSinceAboveTheCounterIsResyncRequired(): void
    {
        [, $top] = $this->pullAll();

        $response = $this->send($this->call('GET', '/sync/pull?since=' . ($top + 1), token: $this->ownerToken));

        self::assertProblem($response, 410, 'resync_required');
        self::assertSame(200, $this->send($this->call('GET', '/sync/pull?since=' . $top, token: $this->ownerToken))->getStatusCode());
    }

    public function testABadSinceOrLimitIs400(): void
    {
        foreach (['', 'since=-1', 'since=x', 'since=0&limit=0', 'since=0&limit=501', 'since=1.5'] as $query) {
            $response = $this->sendInvalid($this->call('GET', '/sync/pull?' . $query, token: $this->ownerToken), 'syncPull');
            self::assertProblem($response, 400, 'invalid_request');
        }
    }

    public function testAPullDuringAWriteSeesOnlyCommittedGapFreeRevisions(): void
    {
        $this->write('labels', self::id(), ['name' => 'Keller']);
        [, $before] = $this->pullAll();
        $writer = Connection::fromEnvironment();
        $writer->beginTransaction();
        $revision = (new RevisionCounter($writer))->next($this->workspace);
        $insert = $writer->prepare(
            "INSERT INTO labels (id, workspace_id, name, name_key, created_at, updated_at, revision) VALUES (?, ?, 'Halb', 'halb', '2026-11-18 10:00:00.000', '2026-11-18 10:00:00.000', ?)",
        );
        self::assertNotFalse($insert);
        $insert->execute([self::id(), $this->workspace, $revision]);

        try {
            [$records, $last] = $this->pullAll();
            self::assertSame($before, $last, 'the uncommitted revision is not examined');
            self::assertNotContains('Halb', array_map(static fn(array $r): mixed => $r['fields']['name'] ?? null, $records));
        } finally {
            $writer->commit();
        }

        $page = $this->pull($before);
        self::assertSame($revision, $page['last_revision']);
        self::assertSame('Halb', $page['records'][0]['fields']['name'] ?? null);
    }
}
