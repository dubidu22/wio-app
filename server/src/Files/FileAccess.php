<?php

declare(strict_types=1);

namespace Wio\Files;

use Wio\Auth\AuthContext;
use Wio\Database\Sql;
use Wio\Sync\ReadScope;

/**
 * Which hashes a caller may download (D-221, D-224): those a non-deleted
 * picture or note in the caller's read scope (D-225) points at. The answer
 * names the Content-Type to send (D-227).
 */
final class FileAccess
{
    /** Picture types sent as recorded; anything else goes out as application/octet-stream. */
    public const array PICTURE_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'image/heic'];

    /** Voice notes are AAC-LC in M4A (D-58). */
    public const string AUDIO_TYPE = 'audio/mp4';

    public const string OTHER_TYPE = 'application/octet-stream';

    public function __construct(private readonly Sql $sql) {}

    /**
     * The Content-Type for a hash the caller may read, or null when no
     * record the caller may read points at it.
     */
    public function contentType(AuthContext $caller, string $sha256): ?string
    {
        $pictures = ReadScope::of($caller, 'pictures');
        if ($pictures !== null) {
            [$where, $bind] = $pictures;
            $types = array_map(
                Sql::text(...),
                array_column($this->sql->rows("SELECT DISTINCT file_mime FROM pictures WHERE {$where} AND file_sha256 = ? AND deleted_at IS NULL", [...$bind, $sha256]), 'file_mime'),
            );
            if ($types !== []) {
                return \count($types) === 1 && \in_array($types[0], self::PICTURE_TYPES, true) ? $types[0] : self::OTHER_TYPE;
            }
        }
        $notes = ReadScope::of($caller, 'notes');
        if ($notes !== null) {
            [$where, $bind] = $notes;
            if ($this->sql->row("SELECT 1 AS found FROM notes WHERE {$where} AND audio_sha256 = ? AND deleted_at IS NULL LIMIT 1", [...$bind, $sha256]) !== null) {
                return self::AUDIO_TYPE;
            }
        }

        return null;
    }
}
