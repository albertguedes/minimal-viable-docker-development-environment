<?php
/**
 * bootstrap.php - PHPUnit bootstrap file
 *
 * Sets up autoloading and environment for tests.
 */

declare(strict_types=1);

$projectRoot = dirname(__DIR__);

if (isset($_SERVER['POSTGRES_HOST'])) {
    putenv('POSTGRES_HOST=' . $_SERVER['POSTGRES_HOST']);
}

require_once $projectRoot . '/vendor/autoload.php';