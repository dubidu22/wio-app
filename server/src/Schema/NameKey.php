<?php

declare(strict_types=1);

namespace Wio\Schema;

use Normalizer;

/**
 * The comparison key for names and e-mails that are unique per workspace
 * (D-51): Unicode NFC, trimmed, inner white space collapsed to one space,
 * lower case. "Küche", " küche " and "KÜCHE" share a key; "Kuche" does not.
 * The key is made here, not by a database collation, so it does not depend on
 * the MariaDB version.
 */
final class NameKey
{
    private function __construct() {}

    public static function of(string $name): string
    {
        $normalized = Normalizer::normalize($name, Normalizer::FORM_C);
        if (!is_string($normalized)) {
            throw new \InvalidArgumentException('The name is not valid UTF-8.');
        }

        $collapsed = preg_replace('/\s+/u', ' ', $normalized);
        if (!is_string($collapsed)) {
            throw new \InvalidArgumentException('The name is not valid UTF-8.');
        }

        return mb_strtolower(trim($collapsed, ' '), 'UTF-8');
    }
}
