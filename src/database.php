<?php
declare(strict_types=1);

/**
 * database.php - php script to test the connection to postgresql server on
 *                database docker container.
 *
 * created: 2022-12-07
 * author: albert r. carnier guedes (albert@teko.net.br)
 *
 * Distributed under the MIT License. See LICENSE for more information.
 */

$host     = getenv('POSTGRES_HOST') ?: 'postgresql-container';
$port     = getenv('POSTGRES_PORT') ?: '5432';
$dbname   = getenv('POSTGRES_DB') ?: 'dockerdb';
$user     = getenv('POSTGRES_USER') ?: 'docker';
$password = getenv('POSTGRES_PASSWORD') ?: '';

$dsn = "host={$host} port={$port} dbname={$dbname} user={$user} password={$password}";

$conn = @pg_connect($dsn);
if (false === $conn) {
    echo "Error: Unable to connect to '{$dbname}' on '{$host}:{$port}'.";
    exit(1);
}

$stat = pg_connection_status($conn);
if (PGSQL_CONNECTION_OK === $stat) {
    echo "Connected to '{$dbname}' on '{$host}:{$port}'.";
} else {
    echo "Error: Connection to '{$dbname}' on '{$host}:{$port}' is broken.";
    pg_close($conn);
    exit(1);
}

pg_close($conn);