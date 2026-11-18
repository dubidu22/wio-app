<?php

declare(strict_types=1);

namespace Wio\AppVersion;

/**
 * The version an app sends in `Wio-App-Version` (D-140). Only
 * `major.minor.patch` takes part in comparisons; a `+build` part is accepted
 * and ignored, as in Semantic Versioning precedence (D-141).
 */
final readonly class AppVersion
{
    public const string HEADER = 'Wio-App-Version';

    /** The contract's pattern for the header (components/parameters/WioAppVersion). */
    public const string PATTERN = '/^([0-9]{1,9})\.([0-9]{1,9})\.([0-9]{1,9})(\+[0-9]{1,9})?$/D';

    /** The contract's maxLength for the header. */
    public const int MAX_LENGTH = 32;

    /** The contract's pattern for `Problem.minimum_app_version`: no build part. */
    public const string MINIMUM_PATTERN = '/^[0-9]{1,9}\.[0-9]{1,9}\.[0-9]{1,9}$/D';

    private function __construct(
        public int $major,
        public int $minor,
        public int $patch,
    ) {}

    /**
     * The version in a header value, or null when the value breaks the
     * contract's pattern or length.
     */
    public static function parse(string $value): ?self
    {
        if (\strlen($value) > self::MAX_LENGTH || preg_match(self::PATTERN, $value, $parts) !== 1) {
            return null;
        }

        return new self((int) $parts[1], (int) $parts[2], (int) $parts[3]);
    }

    /**
     * A minimum version as committed in MinimumAppVersion; it must not carry
     * a build part.
     */
    public static function minimum(string $value): self
    {
        $version = preg_match(self::MINIMUM_PATTERN, $value) === 1 ? self::parse($value) : null;
        if ($version === null) {
            throw new \LogicException('The minimum app version must be major.minor.patch.');
        }

        return $version;
    }

    public function isBelow(self $other): bool
    {
        return [$this->major, $this->minor, $this->patch] < [$other->major, $other->minor, $other->patch];
    }

    public function __toString(): string
    {
        return "{$this->major}.{$this->minor}.{$this->patch}";
    }
}
