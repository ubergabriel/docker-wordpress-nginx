FROM wordpress:6.7-php8.3-fpm-alpine

LABEL description="WordPress with Nginx and PHP-FPM for Sevalla"

RUN apk add --no-cache nginx \
    && rm -f /etc/nginx/http.d/default.conf \
    && mkdir -p /run/nginx /var/log/nginx

COPY nginx/conf/nginx.conf /etc/nginx/nginx.conf
COPY nginx/conf/conf.d/default.conf /etc/nginx/conf.d/default.conf
COPY docker/start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/start.sh"]
