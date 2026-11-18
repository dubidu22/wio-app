<?php

declare(strict_types=1);

namespace Wio\AppVersion;

/**
 * The oldest app version the server still serves (D-145). Apps below it get
 * `426 upgrade_required` on every operation.
 *
 * Null until the first store release. Raise it only in a reviewed PR, and
 * only after the new version is live in every store and on the web: raising
 * it makes every older app stop syncing until it is updated.
 */
final class MinimumAppVersion
{
    /** `major.minor.patch`, or null for no minimum. */
    public const ?string VALUE = null;

    private function __construct() {}
}
