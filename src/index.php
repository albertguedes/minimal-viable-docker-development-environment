<?php
/**
 * index.php - PHP status page
 *
 * created: 2022-12-07
 * author: albert r. carnier guedes (albert@teko.net.br)
 *
 * Distributed under the MIT License. See LICENSE for more information.
 */

header('Content-Type: text/html');

$status = [
    'status' => 'ok',
    'php_version' => PHP_VERSION,
    'timestamp' => date('c'),
];

echo "<!DOCTYPE html>\n";
echo "<html>\n<head><title>PHP Status</title></head>\n<body>\n";
echo "<h1>PHP Status</h1>\n";
echo "<ul>\n";
foreach ($status as $key => $value) {
    echo "<li><strong>" . htmlspecialchars($key) . ":</strong> " . htmlspecialchars((string)$value) . "</li>\n";
}
echo "</ul>\n";
echo "</body>\n";
echo "</html>\n";