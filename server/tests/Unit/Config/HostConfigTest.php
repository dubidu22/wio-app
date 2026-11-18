<?php

declare(strict_types=1);

namespace Wio\Tests\Unit\Config;

use PHPUnit\Framework\TestCase;
use RuntimeException;
use Wio\Config\HostConfig;

/**
 * D-161: the host config file outside the web root.
 */
final class HostConfigTest extends TestCase
{
    private string $file;

    protected function setUp(): void
    {
        $this->file = sys_get_temp_dir() . '/wio-host-config-' . bin2hex(random_bytes(6)) . '.php';
    }

    protected function tearDown(): void
    {
        if (is_file($this->file)) {
            unlink($this->file);
        }
        putenv('WIO_TEST_HOST_A');
        putenv('WIO_TEST_HOST_B');
    }

    public function testAMissingFileSetsNothing(): void
    {
        self::assertSame([], HostConfig::load($this->file));
        self::assertFalse(getenv('WIO_TEST_HOST_A'));
    }

    public function testTheFileSetsItsValues(): void
    {
        $this->write("['WIO_TEST_HOST_A' => 'mysql:host=localhost', 'WIO_TEST_HOST_B' => 'b']");

        self::assertSame(['WIO_TEST_HOST_A', 'WIO_TEST_HOST_B'], HostConfig::load($this->file));
        self::assertSame('mysql:host=localhost', getenv('WIO_TEST_HOST_A'));
        self::assertSame('b', getenv('WIO_TEST_HOST_B'));
    }

    public function testTheRealEnvironmentWins(): void
    {
        putenv('WIO_TEST_HOST_A=from-environment');
        $this->write("['WIO_TEST_HOST_A' => 'from-file', 'WIO_TEST_HOST_B' => 'b']");

        self::assertSame(['WIO_TEST_HOST_B'], HostConfig::load($this->file));
        self::assertSame('from-environment', getenv('WIO_TEST_HOST_A'));
    }

    public function testAFileThatReturnsNoArrayFails(): void
    {
        $this->write("'WIO_TEST_HOST_A=x'");

        $this->expectException(RuntimeException::class);
        HostConfig::load($this->file);
    }

    public function testOnlyWioNamesAreAccepted(): void
    {
        $this->write("['PATH' => '/tmp']");

        $this->expectException(RuntimeException::class);
        HostConfig::load($this->file);
    }

    public function testValuesMustBeStrings(): void
    {
        $this->write("['WIO_TEST_HOST_A' => 3306]");

        $this->expectException(RuntimeException::class);
        HostConfig::load($this->file);
    }

    private function write(string $expression): void
    {
        file_put_contents($this->file, "<?php\n\nreturn {$expression};\n");
    }
}
