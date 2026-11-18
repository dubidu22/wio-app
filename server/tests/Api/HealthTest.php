<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

#[Operation('getHealth')]
final class HealthTest extends ContractTestCase
{
    public function testHealthAnswersOkAsJson(): void
    {
        $response = $this->send($this->request('GET', '/health'));

        self::assertSame(200, $response->getStatusCode());
        self::assertSame('application/json', $response->getHeaderLine('Content-Type'));
        self::assertSame(['status' => 'ok'], json_decode((string) $response->getBody(), true, flags: JSON_THROW_ON_ERROR));
    }

    public function testUnknownPathIsNotFound(): void
    {
        $response = $this->sendOutsideContract($this->request('GET', '/no-such-path'));

        self::assertSame(404, $response->getStatusCode());
    }

    public function testHealthAcceptsOnlyGet(): void
    {
        $response = $this->sendOutsideContract($this->request('POST', '/health'));

        self::assertSame(405, $response->getStatusCode());
    }
}
