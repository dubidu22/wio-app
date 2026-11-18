<?php

declare(strict_types=1);

namespace Wio\Tests\Unit;

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;
use Wio\Migration\MigrationException;
use Wio\Migration\MigrationSet;

final class MigrationSetTest extends TestCase
{
    private string $directory;

    protected function setUp(): void
    {
        $this->directory = sys_get_temp_dir() . '/wio-migrations-' . bin2hex(random_bytes(6));
        mkdir($this->directory);
    }

    protected function tearDown(): void
    {
        $files = glob($this->directory . '/*');
        foreach ($files === false ? [] : $files as $file) {
            unlink($file);
        }
        rmdir($this->directory);
    }

    public function testListsFilesInNumberOrderWithChecksums(): void
    {
        $this->write('0002_second.sql', 'SELECT 2;');
        $this->write('0001_first.sql', 'SELECT 1;');
        $this->write('README.md', 'not a migration');

        $migrations = MigrationSet::fromDirectory($this->directory);

        self::assertSame(['0001_first', '0002_second'], array_map(
            static fn($m): string => $m->version,
            $migrations,
        ));
        self::assertSame(hash('sha256', 'SELECT 1;'), $migrations[0]->checksum);
    }

    public function testAnEmptyDirectoryHasNoMigrations(): void
    {
        self::assertSame([], MigrationSet::fromDirectory($this->directory));
    }

    /**
     * @return iterable<string, array{string}>
     */
    public static function badNames(): iterable
    {
        yield 'no number' => ['create_alpha.sql'];
        yield 'three digits' => ['001_create_alpha.sql'];
        yield 'upper case' => ['0001_Create_Alpha.sql'];
        yield 'dash' => ['0001_create-alpha.sql'];
    }

    #[DataProvider('badNames')]
    public function testRejectsBadFileNames(string $name): void
    {
        $this->write($name, 'SELECT 1;');

        $this->expectException(MigrationException::class);
        MigrationSet::fromDirectory($this->directory);
    }

    public function testRejectsTwoFilesWithTheSameNumber(): void
    {
        $this->write('0001_first.sql', 'SELECT 1;');
        $this->write('0001_other.sql', 'SELECT 1;');

        $this->expectException(MigrationException::class);
        $this->expectExceptionMessage('share the number 0001');
        MigrationSet::fromDirectory($this->directory);
    }

    public function testRejectsAMissingDirectory(): void
    {
        $this->expectException(MigrationException::class);
        MigrationSet::fromDirectory($this->directory . '/missing');
    }

    private function write(string $name, string $content): void
    {
        file_put_contents($this->directory . '/' . $name, $content);
    }
}
