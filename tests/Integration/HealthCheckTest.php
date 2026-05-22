<?php
/**
 * HealthCheckTest.php - Integration tests for HTTP endpoints
 *
 * Tests that all web endpoints return expected responses.
 */

declare(strict_types=1);

namespace Tests\Integration;

use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\Attributes\Test;
use PHPUnit\Framework\Attributes\DataProvider;

final class HealthCheckTest extends TestCase
{
    private string $baseUrl;

    protected function setUp(): void
    {
        $this->baseUrl = 'http://localhost:8080';
    }

    #[Test]
    public function rootReturns200(): void
    {
        $response = $this->curlGet('/');
        $this->assertEquals(200, $response['code']);
        $this->assertNotEmpty($response['body']);
    }

    #[Test]
    public function indexPhpReturns200(): void
    {
        $response = $this->curlGet('/index.php');
        $this->assertEquals(200, $response['code']);
        $this->assertStringContainsString('PHP Status', $response['body']);
    }

    #[Test]
    public function databasePhpReturns200(): void
    {
        $response = $this->curlGet('/database.php');
        $this->assertEquals(200, $response['code']);
        $this->assertStringContainsString('Connected to', $response['body']);
    }

    #[Test]
    public function healthReturns200(): void
    {
        $response = $this->curlGet('/health');
        $this->assertEquals(200, $response['code']);
        $this->assertEquals('OK', trim($response['body']));
    }

    #[Test]
    public function metricsPhpReturns200(): void
    {
        $response = $this->curlGet('/metrics.php');
        $this->assertEquals(200, $response['code']);

        $data = json_decode($response['body'], true);
        $this->assertNotNull($data);
        $this->assertEquals('ok', $data['status']);
        $this->assertArrayHasKey('php', $data);
        $this->assertArrayHasKey('database', $data);
    }

    #[Test]
    public function indexHtmlReturns200(): void
    {
        $response = $this->curlGet('/index.html');
        $this->assertEquals(200, $response['code']);
        $this->assertStringContainsString('Hello World', $response['body']);
    }

    #[Test]
    #[DataProvider('invalidPathsProvider')]
    public function invalidPathsReturn404(string $path): void
    {
        $response = $this->curlGet($path);
        $this->assertEquals(404, $response['code']);
    }

    public static function invalidPathsProvider(): array
    {
        return [
            ['/nonexistent.php'],
            ['/invalid.html'],
            ['/../etc/passwd'],
        ];
    }

    private function curlGet(string $path): array
    {
        $url = $this->baseUrl . $path;
        $ch = curl_init();

        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_FOLLOWLOCATION => false,
        ]);

        $body = curl_exec($ch);
        $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            $this->fail("cURL error: $error");
        }

        return [
            'code' => $code,
            'body' => $body ?: '',
        ];
    }
}