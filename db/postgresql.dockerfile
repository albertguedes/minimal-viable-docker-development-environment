#
# postgresql.dockerfile - a dockerfile to create a postgresql server image.
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
# 
# Distributed under the MIT License. See LICENSE for more information.
#
FROM postgres:alpine

# Create a default database and user to postgresql.
ENV POSTGRES_DB dockerdb
ENV POSTGRES_USER docker
ENV POSTGRES_PASSWORD docker
