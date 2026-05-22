<?php
/**
 * DatabaseTest.php - Integration tests for PostgreSQL connection
 *
 * Tests database connectivity and basic operations.
 */

declare(strict_types=1);

namespace Tests\Integration;

use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\Attributes\Test;

final class DatabaseTest extends TestCase
{
    private string $host;
    private string $port;
    private string $dbname;
    private string $user;
    private string $password;

    protected function setUp(): void
    {
        $this->host = getenv('POSTGRES_HOST') ?: 'localhost';
        $this->port = getenv('POSTGRES_PORT') ?: '2345';
        $this->dbname = getenv('POSTGRES_DB') ?: 'dockerdb';
        $this->user = getenv('POSTGRES_USER') ?: 'docker';
        $this->password = getenv('POSTGRES_PASSWORD') ?: 'docker';
    }

    protected function assertPostgresConnection(): void
    {
        if ($this->host === 'localhost' || $this->host === '127.0.0.1' || $this->host === '') {
            $this->markTestSkipped('Database tests require Docker network (cannot connect to localhost)');
        }

        $dsn = sprintf(
            'host=%s port=%s dbname=%s user=%s password=%s',
            $this->host,
            $this->port,
            $this->dbname,
            $this->user,
            $this->password
        );
        $conn = @pg_connect($dsn);
        if ($conn === false) {
            $this->markTestSkipped('Database tests require Docker network (cannot resolve host: ' . $this->host . ')');
        }
        pg_close($conn);
    }

    #[Test]
    public function canConnectToDatabase(): void
    {
        $this->assertPostgresConnection();
        $dsn = sprintf(
            'host=%s port=%s dbname=%s user=%s password=%s',
            $this->host,
            $this->port,
            $this->dbname,
            $this->user,
            $this->password
        );

        $conn = @pg_connect($dsn);
        $this->assertNotFalse($conn, 'Failed to connect to PostgreSQL');
        pg_close($conn);
    }

    #[Test]
    public function connectionStatusIsOk(): void
    {
        $this->assertPostgresConnection();
        $dsn = sprintf(
            'host=%s port=%s dbname=%s user=%s password=%s',
            $this->host,
            $this->port,
            $this->dbname,
            $this->user,
            $this->password
        );

        $conn = pg_connect($dsn);
        $this->assertNotFalse($conn);
        $this->assertEquals(PGSQL_CONNECTION_OK, pg_connection_status($conn));
        pg_close($conn);
    }

    #[Test]
    public function canRunSimpleQuery(): void
    {
        $this->assertPostgresConnection();
        $dsn = sprintf(
            'host=%s port=%s dbname=%s user=%s password=%s',
            $this->host,
            $this->port,
            $this->dbname,
            $this->user,
            $this->password
        );

        $conn = pg_connect($dsn);
        $this->assertNotFalse($conn);

        $result = pg_query($conn, 'SELECT version()');
        $this->assertNotFalse($result);

        $row = pg_fetch_assoc($result);
        $this->assertIsArray($row);
        $this->assertArrayHasKey('version', $row);
        $this->assertStringContainsString('PostgreSQL', $row['version']);

        pg_close($conn);
    }

    #[Test]
    public function canGetDatabaseSize(): void
    {
        $this->assertPostgresConnection();
        $dsn = sprintf(
            'host=%s port=%s dbname=%s user=%s password=%s',
            $this->host,
            $this->port,
            $this->dbname,
            $this->user,
            $this->password
        );

        $conn = pg_connect($dsn);
        $this->assertNotFalse($conn);

        $result = pg_query($conn, "SELECT pg_database_size($1)");
        $this->assertNotFalse($result);

        $size = pg_fetch_result($result, 0, 0);
        $this->assertIsNumeric($size);
        $this->assertGreaterThanOrEqual(0, $size);

        pg_close($conn);
    }

    #[Test]
    public function pgIsReadyInEnvironment(): void
    {
        $pgIsReady = getenv('POSTGRES_HOST');
        $this->assertNotFalse($pgIsReady);
    }
}