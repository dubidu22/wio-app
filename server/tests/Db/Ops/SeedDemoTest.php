<?php

declare(strict_types=1);

namespace Wio\Tests\Db\Ops;

use PDO;
use PHPUnit\Framework\TestCase;
use Wio\Auth\AuthContext;
use Wio\Auth\PasswordHasher;
use Wio\Database\Connection;
use Wio\Database\Sql;
use Wio\Files\FileStore;
use Wio\Ops\CreateOwner;
use Wio\Ops\OpsException;
use Wio\Ops\SeedDemo;
use Wio\Schema\NameKey;
use Wio\Sync\Pull;
use Wio\Tests\Support\DemoWorkspace;
use Wio\Tests\Support\FrozenClock;
use Wio\Tests\Support\MigratedDatabase;

/**
 * bin/seed-demo's class (plan 094, D-399..D-408), tests T1..T10.
 */
final class SeedDemoTest extends TestCase
{
    private const string PASSWORD = 'ein-langes-passwort';

    private const string UMZUEGE = '01990000-0000-7000-8000-000100000001';

    private const string PRIVAT = '01990000-0000-7000-8000-000100000002';

    /** Tables the seed writes, in the demo file's order. */
    private const array TABLES = ['customers', 'sites', 'rooms', 'openings', 'fixtures', 'labels', 'property_keys', 'entries',
        'place_history', 'entity_labels', 'entity_properties', 'notes', 'jobs', 'pictures'];

    private Sql $sql;
    private FrozenClock $clock;
    private CreateOwner $create;
    private string $filesDir;

    public static function setUpBeforeClass(): void
    {
        MigratedDatabase::migrate();
    }

    public static function tearDownAfterClass(): void
    {
        MigratedDatabase::drop();
    }

    protected function setUp(): void
    {
        $this->sql = new Sql(Connection::fromEnvironment());
        MigratedDatabase::empty($this->sql->pdo);
        // 19 Nov 2026 10:00 in Berlin: the file's first job date, so no shift.
        $this->clock = new FrozenClock('2026-11-19 09:00:00.000');
        $this->create = new CreateOwner($this->sql, $this->clock, new PasswordHasher(PasswordHasher::LOWEST));
        $this->filesDir = sys_get_temp_dir() . '/wio-seed-files-' . bin2hex(random_bytes(6));
    }

    protected function tearDown(): void
    {
        if (is_dir($this->filesDir)) {
            $files = new \RecursiveIteratorIterator(
                new \RecursiveDirectoryIterator($this->filesDir, \FilesystemIterator::SKIP_DOTS),
                \RecursiveIteratorIterator::CHILD_FIRST,
            );
            foreach ($files as $file) {
                $file instanceof \SplFileInfo && $file->isDir() ? rmdir($file->getPathname()) : unlink((string) $file);
            }
            rmdir($this->filesDir);
        }
    }

    private function seed(?string $workspaceId, ?string $email = null, string $environment = 'staging', string $file = DemoWorkspace::FILE, ?Sql $sql = null): array
    {
        return (new SeedDemo($environment, $sql ?? $this->sql, $this->clock, new FileStore($this->filesDir, $this->clock), $file))
            ->run($workspaceId, $email);
    }

    /**
     * @return array{workspace_id: string, user_id: string}
     */
    private function owner(string $plan = 'professional', string $email = 'inhaber@example.org'): array
    {
        return $this->create->run('staging', $plan, $email, 'Inhaber', self::PASSWORD);
    }

    /**
     * @return array<string, int>
     */
    private function demoCounts(string $demoWorkspace): array
    {
        $demo = DemoWorkspace::fromFile();
        $counts = [];
        foreach (self::TABLES as $table) {
            $n = \count(array_filter($demo->rows($table), static fn(array $row): bool => $row['workspace_id'] === $demoWorkspace));
            if ($n > 0) {
                $counts[$table] = $n;
            }
        }

        return $counts;
    }

    /**
     * @return array<string, int>
     */
    private function tableCounts(string $workspaceId): array
    {
        $counts = [];
        foreach (self::TABLES as $table) {
            $n = $this->sql->run("SELECT COUNT(*) FROM {$table} WHERE workspace_id = ?", [$workspaceId])->fetchColumn();
            if ($n > 0) {
                $counts[$table] = $n;
            }
        }

        return $counts;
    }

    private function counter(string $workspaceId): int
    {
        return (int) $this->sql->run('SELECT last_revision FROM workspace_counters WHERE workspace_id = ?', [$workspaceId])->fetchColumn();
    }

    /** T1 */
    public function testItLoadsDemoUmzuegeIntoTheOwnersWorkspace(): void
    {
        $ids = $this->owner();
        $seeded = $this->seed($ids['workspace_id']);

        $expected = $this->demoCounts(self::UMZUEGE);
        self::assertSame($expected, $this->tableCounts($ids['workspace_id']));
        self::assertSame($expected, $seeded['counts']);
        self::assertSame('Demo Umzüge', $seeded['demo_workspace']);
        self::assertSame($ids['user_id'], $seeded['owner_id']);
        self::assertSame(1, $this->sql->run('SELECT COUNT(*) FROM users')->fetchColumn(), 'no demo users');
        self::assertSame(1, $this->sql->run('SELECT COUNT(*) FROM workspaces')->fetchColumn(), 'no demo workspace');

        foreach (self::TABLES as $table) {
            foreach ($this->sql->rows("SELECT * FROM {$table}") as $row) {
                self::assertSame($ids['workspace_id'], $row['workspace_id'], $table);
                foreach ($row as $column => $value) {
                    self::assertFalse(\is_string($value) && str_starts_with($value, '01990000-'), "{$table}.{$column} keeps a demo id");
                }
                foreach (['created_by', 'updated_by', 'moved_by'] as $column) {
                    if (\array_key_exists($column, $row) && $row[$column] !== null) {
                        self::assertSame($ids['user_id'], $row[$column], "{$table}.{$column}");
                    }
                }
            }
        }
        foreach (['labels', 'property_keys'] as $table) {
            foreach ($this->sql->rows("SELECT name, name_key FROM {$table}") as $row) {
                self::assertSame(NameKey::of((string) $row['name']), $row['name_key']);
            }
        }
        // References were remapped consistently: every room's site is a seeded site.
        self::assertSame(0, $this->sql->run(
            'SELECT COUNT(*) FROM rooms r LEFT JOIN sites s ON s.id = r.site_id AND s.workspace_id = r.workspace_id WHERE s.id IS NULL',
        )->fetchColumn());
    }

    /** T2 */
    public function testRevisionsComeFromTheCounterInTheFilesOrder(): void
    {
        $ids = $this->owner();
        $this->seed($ids['workspace_id']);

        $n = array_sum($this->demoCounts(self::UMZUEGE));
        $revisions = [];
        foreach (self::TABLES as $table) {
            foreach ($this->sql->rows("SELECT revision FROM {$table}") as $row) {
                $revisions[] = $row['revision'];
            }
        }
        sort($revisions);
        self::assertSame(range(3, $n + 2), $revisions);
        self::assertSame($n + 2, $this->counter($ids['workspace_id']));

        // The file's order holds: a tombstoned entry's revision is above every create before it.
        $demo = DemoWorkspace::fromFile();
        $fileOrder = [];
        foreach ($demo->rows('jobs') as $row) {
            $fileOrder[] = $row['revision'];
        }
        $jobs = array_column($this->sql->rows('SELECT revision FROM jobs ORDER BY date'), 'revision');
        self::assertSame($fileOrder[0] < $fileOrder[1], $jobs[0] < $jobs[1]);
    }

    /** T3 */
    public function testDatesMoveByWholeDaysSoTheFirstJobIsToday(): void
    {
        $ids = $this->owner();
        $seeded = $this->seed($ids['workspace_id']);
        self::assertSame(['2026-11-19', '2026-11-20'], $seeded['job_dates']);
        self::assertSame('2026-11-02 08:03:00.000', $this->sql->run('SELECT created_at FROM customers')->fetchColumn());

        MigratedDatabase::empty($this->sql->pdo);
        // 25 Nov 2026 00:30 in Berlin is still 24 Nov in UTC: Berlin's date counts.
        $this->clock = new FrozenClock('2026-11-24 23:30:00.000');
        $this->create = new CreateOwner($this->sql, $this->clock, new PasswordHasher(PasswordHasher::LOWEST));
        $ids = $this->owner();
        $seeded = $this->seed($ids['workspace_id']);
        self::assertSame(['2026-11-25', '2026-11-26'], $seeded['job_dates']);
        self::assertSame(['2026-11-25', '2026-11-26'], array_column($this->sql->rows('SELECT date FROM jobs ORDER BY date'), 'date'));
        self::assertSame('2026-11-08 08:03:00.000', $this->sql->run('SELECT created_at FROM customers')->fetchColumn());
    }

    /** T4 */
    public function testASecondRunIsRefusedAndChangesNothing(): void
    {
        $ids = $this->owner();
        $this->seed($ids['workspace_id']);
        $counts = $this->tableCounts($ids['workspace_id']);
        $counter = $this->counter($ids['workspace_id']);

        try {
            $this->seed($ids['workspace_id']);
            self::fail('seeded twice');
        } catch (OpsException $e) {
            self::assertSame(SeedDemo::REFUSED_NOT_EMPTY, $e->getMessage());
        }
        self::assertSame($counts, $this->tableCounts($ids['workspace_id']));
        self::assertSame($counter, $this->counter($ids['workspace_id']));
    }

    /** T5 */
    public function testAWorkspaceWithRealDataIsRefused(): void
    {
        $ids = $this->owner();
        $this->sql->transaction(function () use ($ids): void {
            $revision = (new \Wio\Schema\RevisionCounter($this->sql->pdo))->next($ids['workspace_id']);
            $this->sql->run(
                'INSERT INTO customers (id, workspace_id, name, created_at, updated_at, revision) VALUES (?, ?, ?, ?, ?, ?)',
                ['01990000-1111-7000-8000-000000000001', $ids['workspace_id'], 'Echte Kundin', '2026-11-19 08:00:00.000', '2026-11-19 08:00:00.000', $revision],
            );
        });

        $this->expectExceptionObject(new OpsException(SeedDemo::REFUSED_NOT_EMPTY));
        try {
            $this->seed($ids['workspace_id']);
        } finally {
            self::assertSame(['customers' => 1], $this->tableCounts($ids['workspace_id']));
        }
    }

    /** T6 */
    public function testItRefusesEveryEnvironmentButStagingBeforeTouchingTheDatabase(): void
    {
        $untouchable = new Sql(new class extends PDO {
            public function __construct() {}
        });
        foreach (['production', '', 'Staging', 'test'] as $environment) {
            try {
                $this->seed('01990000-1111-7000-8000-000000000001', null, $environment, DemoWorkspace::FILE, $untouchable);
                self::fail('ran in ' . $environment);
            } catch (OpsException $e) {
                self::assertSame(SeedDemo::REFUSED_ENVIRONMENT, $e->getMessage());
            }
        }
    }

    /** T7 */
    public function testItFindsTheOwnerByEMailAndRefusesUnclearOwners(): void
    {
        $ids = $this->owner('professional', 'Inhaber@Example.org');
        $seeded = $this->seed(null, ' inhaber@example.org ');
        self::assertSame($ids['workspace_id'], $seeded['workspace_id']);

        MigratedDatabase::empty($this->sql->pdo);
        $first = $this->owner('professional', 'zwei@example.org');
        $this->owner('personal', 'zwei@example.org');
        $cases = [
            [null, 'zwei@example.org', 'Owners in more than one workspace have this e-mail; name the workspace with --workspace-id.'],
            [null, 'niemand@example.org', 'No owner has this e-mail.'],
            ['01990000-1111-7000-8000-000000000009', null, 'No workspace has this id.'],
            [$first['workspace_id'], 'niemand@example.org', 'The workspace has no owner with this e-mail.'],
            [null, null, 'Name the workspace with --workspace-id or its owner with --email.'],
        ];
        // A second owner in the first workspace makes --email necessary.
        $this->sql->transaction(function () use ($first): void {
            $revision = (new \Wio\Schema\RevisionCounter($this->sql->pdo))->next($first['workspace_id']);
            $this->sql->run(
                "INSERT INTO users (id, workspace_id, role, email, email_key, created_at, updated_at, revision)
                 VALUES (?, ?, 'owner', 'dritte@example.org', 'dritte@example.org', ?, ?, ?)",
                ['01990000-1111-7000-8000-000000000002', $first['workspace_id'], '2026-11-19 08:00:00.000', '2026-11-19 08:00:00.000', $revision],
            );
        });
        $cases[] = [$first['workspace_id'], null, 'The workspace has more than one owner; name one with --email.'];
        foreach ($cases as [$workspaceId, $email, $message]) {
            try {
                $this->seed($workspaceId, $email);
                self::fail('accepted ' . $workspaceId . ' ' . $email);
            } catch (OpsException $e) {
                self::assertSame($message, $e->getMessage());
            }
        }
        foreach (self::TABLES as $table) {
            self::assertSame(0, $this->sql->run("SELECT COUNT(*) FROM {$table}")->fetchColumn(), $table);
        }

        $this->seed($first['workspace_id'], 'zwei@example.org');
        self::assertSame($this->demoCounts(self::UMZUEGE), $this->tableCounts($first['workspace_id']));
    }

    /** T8 */
    public function testAPersonalWorkspaceGetsDemoPrivat(): void
    {
        $ids = $this->owner('personal');
        $seeded = $this->seed($ids['workspace_id']);

        self::assertSame('Demo privat', $seeded['demo_workspace']);
        self::assertSame($this->demoCounts(self::PRIVAT), $this->tableCounts($ids['workspace_id']));
        self::assertSame(0, $this->sql->run('SELECT COUNT(*) FROM customers')->fetchColumn());
    }

    /** T9 */
    public function testABrokenFileLeavesNothingBehind(): void
    {
        $ids = $this->owner();
        $data = json_decode((string) file_get_contents(DemoWorkspace::FILE), true, 64, JSON_THROW_ON_ERROR);
        self::assertIsArray($data);
        $last = \count($data['tables']) - 1;
        self::assertSame('pictures', $data['tables'][$last]['table']);
        // A demo id nobody defines: the remap refuses it.
        $data['tables'][$last]['rows'][0]['room_id'] = '01990000-0000-7000-8000-000500000099';
        $dir = sys_get_temp_dir() . '/wio-seed-demo-' . bin2hex(random_bytes(6));
        mkdir($dir . '/media', 0o700, true);
        $file = $dir . '/demo-workspace.json';
        file_put_contents($file, json_encode($data, JSON_THROW_ON_ERROR));
        foreach (glob(\dirname(DemoWorkspace::FILE) . '/media/*.jpg') ?: [] as $jpg) {
            copy($jpg, $dir . '/media/' . basename($jpg));
        }

        try {
            $this->seed($ids['workspace_id'], null, 'staging', $file);
            self::fail('loaded a broken file');
        } catch (\InvalidArgumentException) {
        } finally {
            array_map('unlink', glob($dir . '/media/*') ?: []);
            rmdir($dir . '/media');
            unlink($file);
            rmdir($dir);
        }
        self::assertSame([], $this->tableCounts($ids['workspace_id']));
        self::assertSame(2, $this->counter($ids['workspace_id']));
    }

    /** T10 */
    public function testPictureFilesAreStoredAndTheOwnerPullsTheData(): void
    {
        $ids = $this->owner();
        $this->seed($ids['workspace_id']);

        $store = new FileStore($this->filesDir, $this->clock);
        $pictures = $this->sql->rows('SELECT file_sha256, file_bytes FROM pictures');
        self::assertCount(5, $pictures);
        foreach ($pictures as $picture) {
            $sha = (string) $picture['file_sha256'];
            $state = $store->state($ids['workspace_id'], $sha);
            self::assertTrue($state['complete'], $sha);
            self::assertSame($picture['file_bytes'], $state['size']);
            self::assertSame($sha, hash_file('sha256', $this->filesDir . '/' . $ids['workspace_id'] . '/' . $sha));
        }

        $page = (new Pull($this->sql))->page(new AuthContext($ids['workspace_id'], $ids['user_id'], 'owner', null, 'device-1'), 0, Pull::MAX_LIMIT);
        $byEntity = [];
        foreach ($page['records'] as $record) {
            $byEntity[$record['entity']] = ($byEntity[$record['entity']] ?? 0) + 1;
        }
        self::assertSame(1, $byEntity['customers'] ?? 0);
        self::assertSame(2, $byEntity['jobs'] ?? 0);
        self::assertSame(5, $byEntity['pictures'] ?? 0);
        self::assertSame($this->counter($ids['workspace_id']), $page['last_revision']);
    }
}
