<?php

declare(strict_types=1);

namespace Wio\Ops;

use RuntimeException;

/**
 * An ops script refused its input; the message is shown to the operator and
 * never contains the password.
 */
final class OpsException extends RuntimeException {}
