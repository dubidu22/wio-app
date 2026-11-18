<?php

declare(strict_types=1);

namespace Wio\Files;

use RuntimeException;

/**
 * A chunk that does not start at the received size (409 `offset_mismatch`).
 */
final class OffsetMismatch extends RuntimeException
{
    public function __construct(public readonly int $receivedBytes)
    {
        parent::__construct('The chunk does not start at the received size.');
    }
}
