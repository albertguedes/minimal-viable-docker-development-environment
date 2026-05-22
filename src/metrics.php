<?php
declare(strict_types=1);

header('Content-Type: application/json');

$host = getenv('POSTGRES_HOST') ?: '127.0.0.1';
$port = getenv('POSTGRES_PORT') ?: '5432';
$dbname = getenv('POSTGRES_DB') ?: 'dockerdb';
$user = getenv('POSTGRES_USER') ?: 'docker';
$password = getenv('POSTGRES_PASSWORD') ?: '';

$metrics = [
    'status' => 'ok',
    'timestamp' => date('c'),
    'uptime' => time() - (file_exists('/proc/uptime') ? (int)explode(' ', file_get_contents('/proc/uptime'))[0] : 0),
    'database' => null,
    'php' => [
        'version' => PHP_VERSION,
        'memory_usage' => memory_get_usage(true),
        'peak_memory' => memory_get_peak_usage(true),
    ]
];

$conn = @pg_connect("host={$host} port={$port} dbname={$dbname} user={$user} password={$password}");
if ($conn) {
    $result = pg_query_params($conn, "SELECT pg_database_size($1) as size, (SELECT COUNT(*) FROM pg_stat_activity WHERE datname = $1) as connections", [$dbname]);
    if ($result) {
        $row = pg_fetch_assoc($result);
        $metrics['database'] = [
            'connected' => true,
            'size_bytes' => (int)$row['size'],
            'size_human' => round((int)$row['size'] / 1024 / 1024, 2) . ' MB',
            'connections' => (int)$row['connections']
        ];
    }
    pg_close($conn);
} else {
    $metrics['database'] = ['connected' => false];
}

echo json_encode($metrics, JSON_PRETTY_PRINT);