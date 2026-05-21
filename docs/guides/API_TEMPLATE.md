# API Documentation Template

Use this template to document your application APIs.

---

## Base URL

```
Development: http://localhost:8080
```

---

## Endpoints

### GET /

**Description**: Returns the nginx welcome page.

**Response**:
```json
{
  "status": 200,
  "body": "<html>..."
}
```

---

### GET /index.php

**Description**: Returns PHP configuration info.

**Response**: HTML page with PHP info.

---

### GET /database.php

**Description**: Tests PostgreSQL database connection.

**Response**:
```json
{
  "status": "connected",
  "message": "Connected to 'dockerdb' on 'postgresql-container:5432'."
}
```

**Error Response**:
```json
{
  "status": "error",
  "message": "Error: Unable to connect to 'dockerdb' on 'postgresql-container:5432'."
}
```

---

## Data Models

### User

```json
{
  "id": 1,
  "username": "string",
  "email": "string",
  "created_at": "2025-01-01T00:00:00Z",
  "updated_at": "2025-01-01T00:00:00Z"
}
```

### Session

```json
{
  "id": 1,
  "session_id": "string",
  "user_id": 1,
  "data": "string",
  "expires_at": "2025-01-01T00:00:00Z"
}
```

---

## Error Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Bad Request |
| 401 | Unauthorized |
| 404 | Not Found |
| 500 | Internal Server Error |
| 502 | Bad Gateway |
| 503 | Service Unavailable |

---

## Authentication

Describe authentication methods here (JWT, API Key, OAuth, etc.)

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| General | 30 requests/second |
| API | 10 requests/second |

---

## Headers

| Header | Description |
|--------|-------------|
| `Content-Type` | `application/json` |
| `X-Requested-With` | XMLHttpRequest |
| `Authorization` | Bearer token |