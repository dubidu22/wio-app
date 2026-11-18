<?php

declare(strict_types=1);

namespace Wio\Sync;

use RuntimeException;

/**
 * A pushed change the server refuses (D-175). The change's transaction is
 * rolled back and the rejection is remembered under its change_id (D-172).
 * The detail is for logs and must never contain a submitted value.
 */
final class Rejected extends RuntimeException
{
    public const string PERMISSION = 'permission';
    public const string DELETED = 'deleted';
    public const string DUPLICATE = 'duplicate';
    public const string INVALID = 'invalid';
    public const string NOT_FOUND = 'not_found';

    private function __construct(public readonly string $reason, string $detail, public readonly ?string $existingId = null)
    {
        parent::__construct($detail);
    }

    public static function permission(string $detail): self
    {
        return new self(self::PERMISSION, $detail);
    }

    public static function deleted(): self
    {
        return new self(self::DELETED, 'The record is deleted.');
    }

    public static function duplicate(string $existingId, string $key): self
    {
        return new self(self::DUPLICATE, "A live record holds the same value ({$key}).", $existingId);
    }

    public static function invalid(string $detail): self
    {
        return new self(self::INVALID, $detail);
    }

    public static function notFound(): self
    {
        return new self(self::NOT_FOUND, 'No such record in this workspace.');
    }
}
