# php.dockerfile - a dockerfile to create a php-fpm server image.
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
# 
# Distributed under the MIT License. See LICENSE for more information.
#
FROM php:fpm-alpine

# Install php modules to php-pgsql.
RUN apk add --no-cache libpq-dev
RUN docker-php-ext-install pgsql
