<?php

declare(strict_types=1);

require __DIR__ . '/../vendor/autoload.php';

// On the hosting: config.php outside the web root, written by the deploy (D-161).
Wio\Config\HostConfig::load(__DIR__ . '/../config.php');

Wio\App::create()->run();
