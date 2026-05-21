#
# php.dockerfile - a dockerfile to create a php-fpm server image.
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
#
# Distributed under the MIT License. See LICENSE for more information.
#
FROM php:8.4-fpm-alpine

RUN apk add --no-cache libpq-dev postgresql-client autoconf bison flex gcc g++ make libc-dev musl-dev re2c \
    && docker-php-ext-install pgsql pdo pdo_pgsql \
    && docker-php-ext-install redis \
    && pecl install xdebug \
    && docker-php-ext-enable xdebug redis \
    && adduser -D -u 82 -S www-data \
    && chown -R www-data:www-data /var/www

COPY ./xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

USER www-data