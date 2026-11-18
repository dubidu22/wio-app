<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

use Slim\Psr7\Factory\StreamFactory;
use Wio\Tests\Api\Operation;

/**
 * The push envelope (D-191): limits, and requests the server refuses as a
 * whole because a change cannot be answered by its change_id.
 */
#[Operation('syncPush')]
final class PushRequestTest extends SyncTestCase
{
    public function testMoreThan200ChangesIs413(): void
    {
        $changes = array_map(static fn(int $i): array => self::change('labels', self::id(), fields: ['name' => "L{$i}"]), range(1, 201));

        $response = $this->sendInvalid($this->call('POST', '/sync/push', ['changes' => $changes], token: $this->ownerToken), 'syncPush');

        self::assertProblem($response, 413, 'too_many_changes');
        self::assertSame(0, $this->fixtures->count('labels'));
    }

    public function testABodyAbove2MiBIs413(): void
    {
        $changes = array_map(static fn(int $i): array => self::change('notes', self::id(), fields: ['subject_type' => 'entry', 'subject_id' => self::id(), 'text' => str_repeat('x', 11000)]), range(1, 200));

        $response = $this->send($this->call('POST', '/sync/push', ['changes' => $changes], token: $this->ownerToken));

        self::assertProblem($response, 413, 'payload_too_large');
        self::assertSame(0, $this->fixtures->count('applied_changes'));
    }

    public function testExactly200ChangesAreAnswered(): void
    {
        $changes = array_map(static fn(int $i): array => self::change('labels', self::id(), fields: ['name' => "L{$i}"]), range(1, 200));

        self::assertCount(200, $this->push($changes));
    }

    public function testABrokenEnvelopeIs400AndChangesNothing(): void
    {
        $good = self::change('labels', self::id(), fields: ['name' => 'Keller']);
        $broken = [
            'no changes' => [],
            'empty list' => ['changes' => []],
            'extra property' => ['changes' => [$good], 'device' => 'x'],
            'change_id missing' => ['changes' => [$good, array_diff_key($good, ['change_id' => 1])]],
            'change_id not a UUID' => ['changes' => [$good, ['change_id' => 'eins'] + $good]],
            'fields a list' => ['changes' => [$good, ['fields' => ['a']] + $good]],
            'base_revision negative' => ['changes' => [$good, ['base_revision' => -1] + $good]],
            'device_time not a time' => ['changes' => [$good, ['device_time' => 'gestern'] + $good]],
            'unknown change property' => ['changes' => [$good, $good + ['extra' => 1]]],
        ];
        foreach ($broken as $case => $body) {
            $response = $this->sendInvalid($this->call('POST', '/sync/push', $body, token: $this->ownerToken), 'syncPush');
            self::assertProblem($response, 400, 'invalid_request');
            self::assertSame(0, $this->fixtures->count('labels'), $case);
        }
    }

    public function testUpperCaseIdsAreStoredInLowerCaseAndTheChangeIdIsAnsweredAsSent(): void
    {
        $customer = self::id();
        $site = self::id();
        $this->write('customers', $customer, ['name' => 'Familie Beispiel']);
        $result = $this->pushOne(self::change('sites', strtoupper($site), fields: ['customer_id' => strtoupper($customer)], changeId: strtoupper(self::id())));

        self::assertSame('applied', $result['status']);
        self::assertSame($customer, $this->sql->row('SELECT customer_id FROM sites WHERE id = ?', [$site])['customer_id'] ?? null);
    }

    public function testABodyThatIsNotJsonIs400(): void
    {
        $request = $this->call('POST', '/sync/push', token: $this->ownerToken)
            ->withHeader('Content-Type', 'application/json')
            ->withBody((new StreamFactory())->createStream('{"changes": ['));

        self::assertProblem($this->sendInvalid($request, 'syncPush'), 400, 'invalid_request');
    }

    public function testEveryChangeGetsADetailFreeOfSubmittedValues(): void
    {
        $secret = 'geheim-' . bin2hex(random_bytes(4));
        $result = $this->pushOne(self::change('labels', self::id(), fields: ['name' => str_repeat($secret, 20)]));

        self::assertRejected('invalid', $result);
        self::assertStringNotContainsString($secret, self::str($result['detail'] ?? ''));
        $result = $this->pushOne(self::change('labels', self::id(), fields: [$secret => 'x']));
        self::assertStringNotContainsString($secret, self::str($result['detail'] ?? ''));
    }
}
