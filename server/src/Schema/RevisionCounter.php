<?php

declare(strict_types=1);

namespace Wio\Schema;

use PDO;
use PDOStatement;
use RuntimeException;

/**
 * Hands out the revision of each change, counted per workspace (D-52).
 *
 * next() must run inside the transaction that writes the change: the row lock
 * on the workspace's counter serializes writers of that workspace until the
 * transaction ends, so two changes never share a revision and revisions are
 * committed in order. Writers of other workspaces are not blocked.
 */
final class RevisionCounter
{
    public function __construct(private readonly PDO $pdo) {}

    /**
     * Creates the counter of a new workspace, in the transaction that
     * creates the workspace.
     */
    public function start(string $workspaceId): void
    {
        $this->prepare('INSERT INTO workspace_counters (workspace_id, last_revision) VALUES (?, 0)')
            ->execute([$workspaceId]);
    }

    public function next(string $workspaceId): int
    {
        if (!$this->pdo->inTransaction()) {
            throw new RuntimeException('A revision must be taken inside the transaction of its change.');
        }

        $update = $this->prepare(
            'UPDATE workspace_counters SET last_revision = LAST_INSERT_ID(last_revision + 1) WHERE workspace_id = ?',
        );
        $update->execute([$workspaceId]);
        if ($update->rowCount() !== 1) {
            throw new RuntimeException(sprintf('Workspace %s has no revision counter.', $workspaceId));
        }

        $select = $this->pdo->query('SELECT LAST_INSERT_ID()');
        $value = $select === false ? false : $select->fetchColumn();
        if (!is_numeric($value)) {
            throw new RuntimeException('Cannot read the new revision.');
        }

        return (int) $value;
    }

    private function prepare(string $sql): PDOStatement
    {
        $statement = $this->pdo->prepare($sql);
        if ($statement === false) {
            throw new RuntimeException('Cannot prepare: ' . $sql);
        }

        return $statement;
    }
}
