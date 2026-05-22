#
# nginx.dockerfile - nginx image
#
FROM nginx:1.27-alpine

RUN chown -R nginx:nginx /usr/share/nginx/html /var/cache/nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

COPY --chown=nginx:nginx ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx ./nginx/default.conf /etc/nginx/conf.d/default.conf