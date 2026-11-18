<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Auth;

use PHPUnit\Framework\Attributes\DataProvider;
use Wio\Tests\Api\Contract;
use Wio\Tests\Api\DatabaseTestCase;
use Wio\Tests\Api\Operation;

/**
 * The sign-in action checks its body like the closed SignInRequest schema
 * (D-93, D-116), plan 005 test T9: everything the contract rejects gets
 * 400 invalid_request, and the shared invalid examples are among the cases.
 */
#[Operation('signIn')]
final class SignInRequestTest extends DatabaseTestCase
{
    /**
     * @return iterable<string, array{array<string, mixed>}>
     */
    public static function invalidBodies(): iterable
    {
        $valid = ['email' => 'inhaber@example.org', 'password' => 'x', 'device_name' => 'Pixel Test'];
        yield 'unknown field' => [$valid + ['remember_me' => true]];
        yield 'missing password' => [['email' => 'inhaber@example.org', 'device_name' => 'Pixel Test']];
        yield 'password not a string' => [['password' => 12345] + $valid];
        yield 'empty password' => [['password' => ''] + $valid];
        yield 'password too long' => [['password' => str_repeat('ä', 1025)] + $valid];
        yield 'e-mail too short' => [['email' => 'a@'] + $valid];
        yield 'device name too long' => [['device_name' => str_repeat('x', 101)] + $valid];
        yield 'workspace id not a uuid' => [$valid + ['workspace_id' => 'zuhause']];
        $files = glob(Contract::EXAMPLES . '/invalid/request.SignInRequest.*.json');
        self::assertNotEmpty($files);
        foreach ($files === false ? [] : $files as $file) {
            $body = json_decode((string) file_get_contents($file), true, 8, JSON_THROW_ON_ERROR);
            self::assertIsArray($body);
            /** @var array<string, mixed> $body */
            yield basename($file) => [$body];
        }
    }

    /**
     * @param array<string, mixed> $body
     */
    #[DataProvider('invalidBodies')]
    public function testABodyTheContractRejectsGets400(array $body): void
    {
        $response = $this->sendInvalid($this->call('POST', '/auth/sign-in', $body), 'signIn');

        self::assertProblem($response, 400, 'invalid_request');
        self::assertSame(0, $this->fixtures->count('sign_in_failures'), 'a malformed request is not a failed sign-in');
    }

    public function testTheLongestValidValuesAreAccepted(): void
    {
        $this->fixtures->user($this->fixtures->workspace(), password: str_repeat('ä', 1024));

        $response = $this->signIn(['email' => 'inhaber@example.org', 'password' => str_repeat('ä', 1024), 'device_name' => str_repeat('x', 100)]);

        self::assertSame(200, $response->getStatusCode());
    }

    public function testNotJsonGets400(): void
    {
        $request = $this->call('POST', '/auth/sign-in', ['email' => 'x'])
            ->withBody((new \Slim\Psr7\Factory\StreamFactory())->createStream('{"email": '));

        self::assertProblem($this->sendInvalid($request, 'signIn'), 400, 'invalid_request');
    }

    public function testTheDetailNeverEchoesASubmittedValue(): void
    {
        $response = $this->sendInvalid($this->call('POST', '/auth/sign-in', ['geheimes Passwort' => 'x', 'email' => 'inhaber@example.org', 'password' => 'x', 'device_name' => 'x']), 'signIn');

        self::assertProblem($response, 400, 'invalid_request');
        self::assertStringNotContainsString('geheimes', (string) $response->getBody());
    }
}
