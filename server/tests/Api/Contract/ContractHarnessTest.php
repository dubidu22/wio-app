<?php

declare(strict_types=1);

namespace Wio\Tests\Api\Contract;

use League\OpenAPIValidation\PSR7\Exception\ValidationFailed;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Psr7\Factory\ResponseFactory;
use Wio\Tests\Api\ContractTestCase;
use Wio\Tests\Api\Operation;

/**
 * Proves the harness of D-93 and D-94 can fail: a response outside the
 * contract, a request outside the contract, an undeclared operation and a
 * described request sent as "outside" are all caught.
 */
final class ContractHarnessTest extends ContractTestCase
{
    private ?ResponseInterface $fakeResponse = null;

    #[\Override]
    protected function app(): RequestHandlerInterface
    {
        $response = $this->fakeResponse;
        if ($response === null) {
            return parent::app();
        }

        return new class ($response) implements RequestHandlerInterface {
            public function __construct(private readonly ResponseInterface $response) {}

            #[\Override]
            public function handle(ServerRequestInterface $request): ResponseInterface
            {
                return $this->response;
            }
        };
    }

    #[Operation('getHealth')]
    public function testAResponseOutsideTheContractFails(): void
    {
        $response = (new ResponseFactory())->createResponse(200)->withHeader('Content-Type', 'application/json');
        $response->getBody()->write('{"status":"broken"}');
        $this->fakeResponse = $response;

        $this->expectException(ValidationFailed::class);
        $this->send($this->request('GET', '/health'));
    }

    #[Operation('getHealth')]
    public function testAnUndeclaredStatusFails(): void
    {
        $this->fakeResponse = (new ResponseFactory())->createResponse(418);

        $this->expectException(ValidationFailed::class);
        $this->send($this->request('GET', '/health'));
    }

    #[Operation('getHealth')]
    public function testARequestOutsideTheContractFails(): void
    {
        $this->expectException(ValidationFailed::class);
        $this->send($this->request('GET', '/no-such-path'));
    }

    public function testAnUndeclaredOperationFails(): void
    {
        try {
            $this->send($this->request('GET', '/health'));
        } catch (\Throwable $e) {
            self::assertStringContainsString("without declaring #[Operation('getHealth')]", $e->getMessage());

            return;
        }
        self::fail('An undeclared operation was accepted');
    }

    public function testADescribedRequestCannotBeSentAsOutside(): void
    {
        try {
            $this->sendOutsideContract($this->request('GET', '/health'));
        } catch (\Throwable $e) {
            self::assertStringContainsString('use send()', $e->getMessage());

            return;
        }
        self::fail('A described request was sent outside the contract');
    }
}
