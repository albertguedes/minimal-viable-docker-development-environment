<?php

$host     = 'd-postgresql-container';
$port     = '5432';
$dbname   = 'dockerdb';
$user     = 'docker';
$password = 'docker';

$dsn = "host={$host} port={$port} dbname={$dbname} user={$user} password={$password}";

$conn = pg_connect($dsn);

$stat = pg_connection_status($conn);
if( $stat === PGSQL_CONNECTION_OK ){
    echo "Connected to '{$dbname}' on '{$host}:{$port}'.";
} 
else {
    echo "Error on connect to '{$dbname}' on '{$host}:{$port}'.";
}    

pg_close($conn);
