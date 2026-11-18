<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Schema;

use PDOException;
use RuntimeException;
use Wio\Database\Connection;
use Wio\Schema\RevisionCounter;

/**
 * D-52: revisions count per workspace, strictly upwards, and writers of one
 * workspace are serialized by the counter row.
 */
final class RevisionCounterTest extends SchemaTestCase
{
    public function testRevisionsCountUpPerWorkspace(): void
    {
        $counter = new RevisionCounter($this->pdo);
        $a = $this->rows->workspace();
        $b = $this->rows->workspace();
        $counter->start($a);
        $counter->start($b);

        self::assertSame([1, 2, 3], [$counter->next($a), $counter->next($a), $counter->next($a)]);
        self::assertSame(1, $counter->next($b));
        self::assertSame(4, $counter->next($a));
    }

    public function testARevisionIsTakenOnlyInsideATransaction(): void
    {
        $this->pdo->rollBack();

        $this->expectException(RuntimeException::class);
        (new RevisionCounter($this->pdo))->next(Rows::uuid());
    }

    public function testAWorkspaceWithoutCounterFails(): void
    {
        $this->expectException(RuntimeException::class);
        (new RevisionCounter($this->pdo))->next(Rows::uuid());
    }

    public function testASecondWriterOfTheSameWorkspaceWaitsForTheFirst(): void
    {
        $this->pdo->rollBack();
        $workspace = $this->rows->workspace();
        (new RevisionCounter($this->pdo))->start($workspace);

        $first = new RevisionCounter($this->pdo);
        $otherPdo = Connection::fromEnvironment();
        $otherPdo->exec('SET SESSION innodb_lock_wait_timeout = 1');
        $second = new RevisionCounter($otherPdo);

        try {
            $this->pdo->beginTransaction();
            self::assertSame(1, $first->next($workspace));

            $otherPdo->beginTransaction();
            try {
                $second->next($workspace);
                self::fail('The second writer must wait while the first holds the counter.');
            } catch (PDOException $e) {
                self::assertSame(1205, $e->errorInfo[1] ?? null, $e->getMessage());
            }
            $otherPdo->rollBack();

            $this->pdo->commit();

            $otherPdo->beginTransaction();
            self::assertSame(2, $second->next($workspace));
            $otherPdo->commit();
        } finally {
            $this->pdo->exec('DELETE FROM workspace_counters');
            $this->pdo->exec('DELETE FROM workspaces');
        }
    }
}
