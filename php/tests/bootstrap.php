<?php
/**
 * bootstrap.php - PHPUnit bootstrap file
 *
 * Sets up environment for tests.
 */

declare(strict_types=1);

if (isset($_SERVER['POSTGRES_HOST'])) {
    putenv('POSTGRES_HOST=' . $_SERVER['POSTGRES_HOST']);
}