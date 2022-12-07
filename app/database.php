<?php
/** 
 * database.php - php script to test the connection to postgresql server on 
 *                database docker container.
 *
 * created: 2022-12-07
 * author: albert r. carnier guedes (albert@teko.net.br)
 * 
 * Distributed under the MIT License. See LICENSE for more information.
 */

// Host info.
$host     = 'postgresql-container';
$port     = '5432';

// Database credentials.
$dbname   = 'dockerdb';
$user     = 'docker';
$password = 'docker';

// Connection string.
$dsn = "host={$host} port={$port} dbname={$dbname} user={$user} password={$password}";

// Connect to server.
$conn = pg_connect($dsn);

// Test the connection.
$stat = pg_connection_status($conn);
if( $stat === PGSQL_CONNECTION_OK ){
    echo "Connected to '{$dbname}' on '{$host}:{$port}'.";
} 
else {
    echo "Error on connect to '{$dbname}' on '{$host}:{$port}'.";
}    

// Close connection.
pg_close($conn);
