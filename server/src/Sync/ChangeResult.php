<?php

declare(strict_types=1);

namespace Wio\Sync;

/**
 * The answer to one pushed change (D-175), as stored in applied_changes and
 * sent in the push result.
 */
final readonly class ChangeResult
{
    public const string APPLIED = 'applied';
    public const string MERGED = 'merged';
    public const string REJECTED = 'rejected';

    public function __construct(
        public string $changeId,
        public string $status,
        public ?int $revision = null,
        public ?string $reason = null,
        public ?string $existingId = null,
        public ?string $detail = null,
    ) {}

    public static function rejected(string $changeId, Rejected $rejection): self
    {
        return new self($changeId, self::REJECTED, null, $rejection->reason, $rejection->existingId, $rejection->getMessage());
    }

    /**
     * @return array<string, int|string>
     */
    public function toJson(): array
    {
        $out = ['change_id' => $this->changeId, 'status' => $this->status];
        if ($this->revision !== null) {
            $out['revision'] = $this->revision;
        }
        if ($this->reason !== null) {
            $out['reason'] = $this->reason;
        }
        if ($this->existingId !== null) {
            $out['existing_id'] = $this->existingId;
        }
        if ($this->detail !== null) {
            $out['detail'] = $this->detail;
        }

        return $out;
    }
}
