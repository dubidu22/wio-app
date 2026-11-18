<?php

declare(strict_types=1);

namespace Wio\Http;

use RuntimeException;

/**
 * A request body the contract does not allow; answered as 400
 * `invalid_request` with this message as `detail`, so the message must never
 * contain a submitted value.
 */
final class InvalidRequest extends RuntimeException {}
