<?php

declare(strict_types=1);

// Deliberately unsafe code, never loaded by the app or deployed. CI runs
// Psalm's taint analysis on this file and expects it to report TaintedSql;
// that proves the security check can fail (D-39).

namespace Wio\Tests\Fixtures\Taint;

use PDO;

final class TaintedSqlFixture
{
    public function find(PDO $pdo): mixed
    {
        $name = $_GET['name'] ?? '';

        return $pdo->query("SELECT * FROM customer WHERE name = '" . $name . "'");
    }
}
