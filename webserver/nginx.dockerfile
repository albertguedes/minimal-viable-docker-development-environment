#
# nginx.dockerfile - a dockerfile to create a nginx image
#
# created: 2022-12-07
# author: albert r. carnier guedes (albert@teko.net.br)
#
# Distributed under the MIT License. See LICENSE for more information.
#
FROM nginx:1.27-alpine

RUN apk add --no-cache curl \
    && chown -R nginx:nginx /usr/share/nginx/html \
    && chown -R nginx:nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx \
    && touch /var/run/nginx.pid \
    && chown nginx:nginx /var/run/nginx.pid

COPY --chown=nginx:nginx ./nginx/default.conf /etc/nginx/conf.d/default.conf
COPY --chown=nginx:nginx ./nginx/ssl.conf /etc/nginx/conf.d/ssl.conf

USER nginx