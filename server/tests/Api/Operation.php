<?php

declare(strict_types=1);

namespace Wio\Tests\Api;

use Attribute;

/**
 * Names the contract operation a test calls (D-94). ContractTestCase refuses
 * a call to an operation the running test does not declare, so the attribute
 * cannot claim coverage the test does not have, and RouteParityTest uses the
 * attributes to prove that every implemented operation has a test.
 */
#[Attribute(Attribute::TARGET_CLASS | Attribute::TARGET_METHOD | Attribute::IS_REPEATABLE)]
final readonly class Operation
{
    public function __construct(public string $operationId) {}
}
