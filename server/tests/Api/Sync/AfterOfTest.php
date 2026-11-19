<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Sync;

/**
 * pictures.after_of on push (plan 071, #71): an after picture follows a
 * picture of the same customer in the same workspace; a deleted before
 * picture is still a valid target; the link is set once at create.
 */
final class AfterOfTest extends SyncTestCase
{
    private const string WRONG_TARGET = 'after_of must point to a picture of the same customer.';

    private const string CHANGED = 'after_of cannot be changed.';

    /** @var array<string, string> Anna's records */
    private array $anna;

    /** @var array<string, string> Ben's records */
    private array $ben;

    protected function setUp(): void
    {
        parent::setUp();
        $this->anna = $this->graph('WIO-0001');
        $this->ben = $this->graph('WIO-0002');
    }

    public function testAnAfterPictureOfAPictureInTheSameRoomIsApplied(): void
    {
        $before = $this->picture(['room_id' => $this->anna['rooms']]);
        $after = self::id();

        $result = $this->pushOne(self::change('pictures', $after, fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $before])));

        self::assertSame('applied', $result['status'], (string) json_encode($result));
        $pulled = $this->pulled('pictures', $after);
        self::assertSame($before, $pulled['after_of'] ?? null);
        self::assertSame($this->anna['customers'], $pulled['customer_id'] ?? null);
    }

    public function testAnAfterPictureWithoutCustomerFollowsAPictureWithoutCustomer(): void
    {
        $before = $this->picture([]);

        self::assertSame('applied', $this->pushOne(self::change('pictures', self::id(), fields: self::file(['after_of' => $before])))['status']);
    }

    public function testAnAfterPictureCanItselfGetAnAfterPicture(): void
    {
        $before = $this->picture(['room_id' => $this->anna['rooms']]);
        $after = $this->picture(['room_id' => $this->anna['rooms'], 'after_of' => $before]);

        self::assertSame('applied', $this->pushOne(self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $after])))['status']);
    }

    public function testAnAfterPictureCannotFollowAnotherCustomersPicture(): void
    {
        $bens = $this->picture(['room_id' => $this->ben['rooms']]);
        $after = self::id();

        $this->assertWrongTarget($this->pushOne(self::change('pictures', $after, fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $bens]))));
        $this->assertWrongTarget($this->pushOne(self::change('pictures', self::id(), fields: self::file(['customer_id' => $this->anna['customers'], 'after_of' => $bens]))), 'customer from fields');
        $this->assertWrongTarget($this->pushOne(self::change('pictures', self::id(), fields: self::file(['after_of' => $bens]))), 'no customer after a customer\'s picture');
        $this->assertWrongTarget($this->pushOne(self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $this->picture([])]))), 'customer\'s picture after one without customer');
        self::assertNull($this->pulled('pictures', $after));
    }

    public function testUnknownAndForeignTargetsGetTheSameAnswerAsAnotherCustomersPicture(): void
    {
        $other = $this->fixtures->workspace('Anderer Betrieb');
        $token = $this->fixtures->token($other, $this->fixtures->user($other, email: 'andere@example.org'))['token'];
        $foreign = self::id();
        $this->write('pictures', $foreign, self::file([]), token: $token);

        $bens = $this->picture(['room_id' => $this->ben['rooms']]);

        $answers = [];
        foreach (['unknown id' => self::id(), 'other workspace' => $foreign, 'other customer' => $bens] as $case => $target) {
            $result = $this->pushOne(self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $target])));
            $this->assertWrongTarget($result, $case);
            unset($result['change_id']);
            $answers[$case] = $result;
        }
        self::assertSame($answers['other customer'], $answers['unknown id']);
        self::assertSame($answers['other customer'], $answers['other workspace']);
    }

    public function testACustomerCannotLinkToAnotherCustomersPicture(): void
    {
        $user = $this->fixtures->user($this->workspace, 'customer', 'kunde@example.org', customerId: $this->anna['customers']);
        $token = $this->fixtures->token($this->workspace, $user)['token'];
        $bens = $this->picture(['room_id' => $this->ben['rooms']]);
        $annas = $this->picture(['room_id' => $this->anna['rooms']]);

        $this->assertWrongTarget($this->pushOne(self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $bens])), $token));
        self::assertSame('applied', $this->pushOne(self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $annas])), $token)['status']);
    }

    public function testADeletedBeforePictureIsStillAValidTarget(): void
    {
        $before = $this->picture(['room_id' => $this->anna['rooms']]);
        $this->write('pictures', $before, op: 'delete', token: $this->secondToken);

        self::assertSame('applied', $this->pushOne(self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $before])))['status']);
    }

    public function testTheLinkCannotBeChangedLater(): void
    {
        $first = $this->picture(['room_id' => $this->anna['rooms']]);
        $second = $this->picture(['room_id' => $this->anna['rooms']]);
        $after = $this->picture(['room_id' => $this->anna['rooms'], 'after_of' => $first]);
        $plain = $this->picture(['room_id' => $this->anna['rooms']]);

        $this->assertChanged($this->pushOne(self::change('pictures', $after, fields: ['after_of' => $second])), 'to another picture');
        $this->assertChanged($this->pushOne(self::change('pictures', $after, fields: ['after_of' => null])), 'to none');
        $this->assertChanged($this->pushOne(self::change('pictures', $plain, fields: ['after_of' => $first])), 'set on an existing picture');
        $this->assertChanged($this->pushOne(self::change('pictures', $first, fields: ['after_of' => $after])), 'a loop');
        self::assertSame($first, $this->linkOf($after));

        $this->write('pictures', $after, ['after_of' => $first, 'width_px' => 800]);
        self::assertSame($first, $this->linkOf($after), 'resending the same value is fine');
        $this->write('pictures', $plain, ['after_of' => null, 'width_px' => 800]);
    }

    public function testARetryGetsTheRememberedAnswer(): void
    {
        $before = $this->picture(['room_id' => $this->anna['rooms']]);
        $after = self::id();
        $valid = self::change('pictures', $after, fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $before]));
        $first = $this->pushOne($valid);
        $count = $this->fixtures->count('pictures');

        self::assertSame($first, $this->pushOne($valid));
        self::assertSame($count, $this->fixtures->count('pictures'));

        $missing = self::id();
        $early = self::change('pictures', self::id(), fields: self::file(['room_id' => $this->anna['rooms'], 'after_of' => $missing]));
        $this->assertWrongTarget($this->pushOne($early));
        $this->write('pictures', $missing, self::file(['room_id' => $this->anna['rooms']]));
        $this->assertWrongTarget($this->pushOne($early), 'the stored rejection, although the target exists now');
    }

    public function testAnAfterPictureCannotMoveToAnotherCustomersRoom(): void
    {
        $before = $this->picture(['room_id' => $this->anna['rooms']]);
        $after = $this->picture(['room_id' => $this->anna['rooms'], 'after_of' => $before]);

        self::assertRejected('invalid', $this->pushOne(self::change('pictures', $after, fields: ['room_id' => $this->ben['rooms']])), 'after picture');
        self::assertRejected('invalid', $this->pushOne(self::change('pictures', $before, fields: ['room_id' => $this->ben['rooms']])), 'before picture with an after picture');
    }

    private function linkOf(string $picture): mixed
    {
        return $this->pulled('pictures', $picture)['after_of'] ?? null;
    }

    /**
     * @param array<string, mixed> $fields
     */
    private function picture(array $fields): string
    {
        $id = self::id();
        $this->write('pictures', $id, self::file($fields));

        return $id;
    }

    /**
     * @param array<string, mixed> $fields
     *
     * @return array<string, mixed>
     */
    private static function file(array $fields): array
    {
        return ['file_sha256' => self::SHA, 'file_bytes' => 1000, 'file_mime' => 'image/jpeg', 'width_px' => 640, 'height_px' => 480] + $fields;
    }

    /**
     * @param array<string, mixed> $result
     */
    private function assertWrongTarget(array $result, string $message = ''): void
    {
        self::assertRejected('invalid', $result, $message);
        self::assertSame(self::WRONG_TARGET, $result['detail'] ?? null, $message);
    }

    /**
     * @param array<string, mixed> $result
     */
    private function assertChanged(array $result, string $message): void
    {
        self::assertRejected('invalid', $result, $message);
        self::assertSame(self::CHANGED, $result['detail'] ?? null, $message);
    }
}
