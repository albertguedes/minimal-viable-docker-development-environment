# Minimal Viable Docker Development Environment

This project aims create a minimal viable development environment with docker, 
i.e., less then it, nothing work. 
Its possible thanks the official images for nginx, php and postgresql, which do
great job.

The scheme is usual: we have 3 containers with a nginx, a php and a postgresql 
containers and a 'app' folder for the source code. All images use 
[Alpine Linux](https://www.alpinelinux.org) as base system to reduce the size 
of containers.

## Installation

To install the package, clone the repository


```
$ git clone https://github.com/albertguedes/minimal-viable-docker-development-environment
```

goes to the folder project and run the docker compose:


```
$ docker-compose up -d
```

Now, run in your browser the address "http://localhost:8080" to see the default 
nginx "index.html" page, and "http://localhost:8080/index.php" to see php info 
page stored on "app" folder.

## Configuration

Each folder - db, php and webserver - has a custom dockerfile tha you can edit 
to add more options, but as you can see, they have almost anything. This is 
because the official images come with many options enabled by default. See on 
references the documentation on [dockhub](https://dockhub.com) of each image.

The "webserver/nginx" folder has a "default.config", where you can adjust to 
your project.

## References

- Docker Documentation : [https://docs.docker.com/](https://docs.docker.com/)
- Nginx Documentation: [https://nginx.org/en/docs/](https://nginx.org/en/docs/)
- PHP FPM Documentation: [https://www.php.net/manual/pt_BR/install.fpm.php](https://www.php.net/manual/pt_BR/install.fpm.php) 
- PostgreSQL Documentation: [https://www.postgresql.org/docs/current/index.html](https://www.postgresql.org/docs/current/index.html)
- Docker images:
    - nginx: [https://hub.docker.com/_/nginx](https://hub.docker.com/_/nginx)
    - php: [https://hub.docker.com/_/php](https://hub.docker.com/_/php)
    - postgresql: [https://hub.docker.com/_/postgres](https://hub.docker.com/_/postgres)
