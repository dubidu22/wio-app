<?php

declare(strict_types=1);

namespace Wio\Files;

use RuntimeException;

/**
 * The complete file does not match its SHA-256 (422 `hash_mismatch`); the
 * partial file is already gone.
 */
final class HashMismatch extends RuntimeException {}
