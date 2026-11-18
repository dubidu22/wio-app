<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use PHPUnit\Framework\TestCase;
use Slim\Psr7\Factory\ServerRequestFactory;
use Wio\App;

final class HealthTest extends TestCase
{
    public function testHealthAnswersOkAsJson(): void
    {
        $request = (new ServerRequestFactory())->createServerRequest('GET', '/health');

        $response = App::create()->handle($request);

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('application/json', $response->getHeaderLine('Content-Type'));
        self::assertSame(['status' => 'ok'], json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR));
    }

    public function testUnknownPathIsNotFound(): void
    {
        $request = (new ServerRequestFactory())->createServerRequest('GET', '/no-such-path');

        $response = App::create()->handle($request);

        self::assertSame(404, $response->getStatusCode());
    }

    public function testHealthAcceptsOnlyGet(): void
    {
        $request = (new ServerRequestFactory())->createServerRequest('POST', '/health');

        $response = App::create()->handle($request);

        self::assertSame(405, $response->getStatusCode());
    }
}
