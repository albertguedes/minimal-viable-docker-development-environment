#
# postgresql.dockerfile - a dockerfile to create a postgresql server image.
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
#
# Distributed under the MIT License. See LICENSE for more information.
#
FROM postgres:17-alpine

RUN mkdir -p /var/lib/postgresql/data && chown postgres:postgres /var/lib/postgresql/data

USER postgres