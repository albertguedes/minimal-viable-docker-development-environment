FROM php:fpm-alpine

# Install php modules to php-pgsql.
RUN apk add --no-cache libpq-dev
RUN docker-php-ext-install pgsql
