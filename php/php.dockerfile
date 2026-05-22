#
# php.dockerfile - a dockerfile to create a php-fpm server image.
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
#
# Distributed under the MIT License. See LICENSE for more information.
#
FROM php:8.4-fpm-alpine

RUN apk add --no-cache libpq-dev postgresql-client \
    && docker-php-ext-install pgsql pdo pdo_pgsql

USER www-data