<?php

declare(strict_types=1);

namespace Wio\Sync;

use RuntimeException;

/**
 * The app's `since` is above the workspace's counter, so the server cannot
 * tell what the app has (D-184): answered as 410 `resync_required`.
 */
final class ResyncRequired extends RuntimeException {}
