# Contributing to Minimal Viable Docker Development Environment

Thank you for your interest in contributing. This document provides guidelines and instructions for contributing to this project.

---

## Ways to Contribute

- **Report bugs** via GitHub Issues
- **Suggest features** via GitHub Issues
- **Submit pull requests** for bugs, features, or documentation
- **Improve documentation** (readme, comments, guides)

---

## Development Workflow

### 1. Fork and Clone

```bash
git clone https://github.com/YOUR_USERNAME/minimal-viable-docker-development-environment.git
cd minimal-viable-docker-development-environment
```

### 2. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 3. Make Changes

- Keep changes focused and atomic
- Follow existing code style
- Test your changes locally before committing

### 4. Test Locally

```bash
# Build images
make build

# Start services
make up

# Run tests
make logs

# Verify everything works
curl http://localhost:8080/
curl http://localhost:8080/index.php
curl http://localhost:8080/database.php

# Stop services
make down
```

### 5. Commit and Push

```bash
git add .
git commit -m "feat: add new feature"
git push origin feature/your-feature-name
```

### 6. Submit Pull Request

- Use clear, descriptive commit messages
- Reference any related GitHub issues
- Describe what the change does and why

---

## Code Style

### Docker and docker-compose

- Use descriptive service names
- Always add comments for non-obvious configuration
- Pin image versions in production-ready configs
- Use environment variables for sensitive data

### Shell Scripts (Makefile)

- Use GNU Make conventions
- Provide help text for each target
- Keep targets atomic and single-purpose

### PHP

- PSR-12 coding standard
- Use strict types (`declare(strict_types=1);`)
- Document functions with docblocks

---

## Security Guidelines

- **Never commit secrets** (passwords, API keys, tokens)
- Use `.env` files for sensitive configuration
- Verify `.gitignore` excludes sensitive files
- Report security vulnerabilities privately to maintainer

---

## Questions?

Open a GitHub Issue for questions about contributing. Response time may vary.

---

## License

By contributing, you agree that your contributions will be licensed under the MIT License.