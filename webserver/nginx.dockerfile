#
# nginx.dockerfile - nginx image
#
FROM nginx:1.27-alpine

RUN chown -R nginx:nginx /usr/share/nginx/html

COPY --chown=nginx:nginx ./nginx/default.conf /etc/nginx/conf.d/default.conf

USER nginx