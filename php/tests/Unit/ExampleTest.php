<?php
/**
 * ExampleTest.php - Sample unit test
 *
 * Demonstrates basic PHPUnit usage with the project.
 */

declare(strict_types=1);

namespace Tests\Unit;

use PHPUnit\Framework\TestCase;

final class ExampleTest extends TestCase
{
    public function testTrueIsTrue(): void
    {
        $this->assertTrue(true);
    }

    public function testPhpVersionIsString(): void
    {
        $this->assertIsString(PHP_VERSION);
    }

    public function testStatusArrayStructure(): void
    {
        $status = [
            'status' => 'ok',
            'php_version' => PHP_VERSION,
            'timestamp' => date('c'),
        ];

        $this->assertArrayHasKey('status', $status);
        $this->assertArrayHasKey('php_version', $status);
        $this->assertArrayHasKey('timestamp', $status);
        $this->assertEquals('ok', $status['status']);
    }

    public function testHtmlSpecialChars(): void
    {
        $input = '<script>alert("xss")</script>';
        $output = htmlspecialchars($input, ENT_QUOTES, 'UTF-8');
        $this->assertStringNotContainsString('<script>', $output);
    }
}