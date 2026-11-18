<?php

declare(strict_types=1);

// Runs Psalm's taint analysis on the deliberately unsafe fixture and exits 0
// only if Psalm reports TaintedSql there. If Psalm stops finding it, the
// security check in CI has silently stopped working (D-39).

$root = dirname(__DIR__);
$command = escapeshellarg($root . '/vendor/bin/psalm')
    . ' --config=' . escapeshellarg($root . '/psalm-taint-fixture.xml')
    . ' --taint-analysis --no-progress --no-cache --output-format=compact 2>&1';

exec($command, $output, $exitCode);
$report = implode(PHP_EOL, $output);

if ($exitCode !== 0 && str_contains($report, 'TaintedSql')) {
    fwrite(STDOUT, 'ok: Psalm reports TaintedSql in the fixture, so the taint check can fail.' . PHP_EOL);
    exit(0);
}

fwrite(STDERR, $report . PHP_EOL);
fwrite(STDERR, sprintf('Psalm did not report TaintedSql in the fixture (exit %d): the taint check is broken.', $exitCode) . PHP_EOL);
exit(1);
