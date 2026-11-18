<?php

declare(strict_types=1);

namespace Wio\Migration;

/**
 * One SQL file in server/migrations/, named NNNN_description.sql.
 */
final readonly class Migration
{
    public function __construct(
        public string $version,
        public string $path,
        public string $checksum,
    ) {}
}
