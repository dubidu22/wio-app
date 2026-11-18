<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use League\OpenAPIValidation\PSR7\Exception\NoPath;
use League\OpenAPIValidation\PSR7\Exception\ValidationFailed;
use League\OpenAPIValidation\PSR7\OperationAddress;
use League\OpenAPIValidation\PSR7\ResponseValidator;
use League\OpenAPIValidation\PSR7\ServerRequestValidator;
use League\OpenAPIValidation\PSR7\ValidatorBuilder;
use PHPUnit\Framework\TestCase;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;
use Psr\Http\Server\RequestHandlerInterface;
use Slim\Psr7\Factory\ServerRequestFactory;
use Wio\App;

/**
 * Base of every API test (D-93): each request is validated against
 * api/openapi.yaml before the app handles it, and each response after. A test
 * may only call operations it declares with #[Operation] (D-94).
 */
abstract class ContractTestCase extends TestCase
{
    private static ?ServerRequestValidator $requestValidator = null;

    private static ?ResponseValidator $responseValidator = null;

    /**
     * The application under test. The harness test replaces it to prove that
     * a response outside the contract fails.
     */
    protected function app(): RequestHandlerInterface
    {
        return App::create();
    }

    /**
     * @param array<string, string> $serverParams for example REMOTE_ADDR
     */
    final protected function request(string $method, string $uri, array $serverParams = []): ServerRequestInterface
    {
        return (new ServerRequestFactory())->createServerRequest($method, $uri, $serverParams);
    }

    /**
     * Sends a request that the contract describes and returns the validated
     * response.
     */
    final protected function send(ServerRequestInterface $request): ResponseInterface
    {
        [$requestValidator, $responseValidator] = self::validators();

        $address = $requestValidator->validate($request);
        $operationId = Contract::operations()[strtoupper($address->method()) . ' ' . $address->path()] ?? null;
        self::assertNotNull($operationId, 'The contract has no operationId for ' . $address->method() . ' ' . $address->path());
        self::assertContains(
            $operationId,
            $this->declaredOperations(),
            "This test calls {$operationId} without declaring #[Operation('{$operationId}')]",
        );

        $response = $this->app()->handle($request);
        $responseValidator->validate($address, $response);

        return $response;
    }

    /**
     * Sends a request that breaks the contract on purpose (a missing token, a
     * closed body with an unknown field) to an operation the contract has,
     * and returns the response validated against that operation. Fails if
     * the request is valid, so this cannot be used to skip validation.
     */
    final protected function sendInvalid(ServerRequestInterface $request, string $operationId): ResponseInterface
    {
        [$requestValidator, $responseValidator] = self::validators();
        self::assertContains(
            $operationId,
            $this->declaredOperations(),
            "This test calls {$operationId} without declaring #[Operation('{$operationId}')]",
        );
        $route = array_search($operationId, Contract::operations(), true);
        self::assertIsString($route, "The contract has no operation {$operationId}");
        [$method, $path] = explode(' ', $route, 2);

        try {
            $requestValidator->validate($request);
        } catch (NoPath $e) {
            self::fail('The contract has no such request at all; use sendOutsideContract(): ' . $e->getMessage());
        } catch (ValidationFailed) {
            $response = $this->app()->handle($request);
            $responseValidator->validate(new OperationAddress($path, strtolower($method)), $response);

            return $response;
        }

        self::fail("The request to {$operationId} is valid; use send()");
    }

    /**
     * Sends a request on purpose outside the contract (an unknown path, a
     * method the path does not have) and returns the response unvalidated.
     * Fails if the contract does describe the request, so this cannot be used
     * to skip validation.
     */
    final protected function sendOutsideContract(ServerRequestInterface $request): ResponseInterface
    {
        [$requestValidator] = self::validators();

        try {
            $requestValidator->validate($request);
        } catch (NoPath) {
            return $this->app()->handle($request);
        }

        self::fail('The contract describes ' . $request->getMethod() . ' ' . $request->getUri()->getPath() . '; use send()');
    }

    /**
     * Operations declared on the test class and on the running test method,
     * found on the call stack.
     *
     * @return list<string>
     */
    final protected function declaredOperations(): array
    {
        $declared = [];
        $class = new \ReflectionClass($this);
        foreach ($class->getAttributes(Operation::class) as $attribute) {
            $declared[] = $attribute->newInstance()->operationId;
        }
        foreach (debug_backtrace(DEBUG_BACKTRACE_PROVIDE_OBJECT | DEBUG_BACKTRACE_IGNORE_ARGS) as $frame) {
            if (($frame['object'] ?? null) !== $this || !str_starts_with($frame['function'], 'test')) {
                continue;
            }
            foreach ($class->getMethod($frame['function'])->getAttributes(Operation::class) as $attribute) {
                $declared[] = $attribute->newInstance()->operationId;
            }
        }

        return $declared;
    }

    /**
     * @return array{ServerRequestValidator, ResponseValidator}
     */
    private static function validators(): array
    {
        if (self::$requestValidator === null || self::$responseValidator === null) {
            $builder = (new ValidatorBuilder())->fromYamlFile(Contract::FILE);
            self::$requestValidator = $builder->getServerRequestValidator();
            self::$responseValidator = $builder->getResponseValidator();
        }

        return [self::$requestValidator, self::$responseValidator];
    }

    /**
     * Unwraps the validator's nested exceptions into one readable line, for
     * assertion messages.
     */
    final protected static function reasons(ValidationFailed $failure): string
    {
        $reasons = [];
        for ($e = $failure; $e !== null; $e = $e->getPrevious()) {
            $reasons[] = $e->getMessage();
        }

        return implode(' <- ', $reasons);
    }
}
