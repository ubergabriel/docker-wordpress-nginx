#!/bin/sh
set -e

# Sevalla provides the web port through $PORT. Use 8080 as a local fallback.
PORT="${PORT:-8080}"

# Nginx must listen on the same port Sevalla routes to.
sed -i "s/listen 80;/listen ${PORT};/" /etc/nginx/http.d/default.conf

# Let the official WordPress entrypoint initialize wp-config.php,
# permissions, and the WordPress files on the persistent volume.
/usr/local/bin/docker-entrypoint.sh php-fpm -D

# Nginx stays in the foreground so Sevalla can monitor the web process.
exec nginx -g 'daemon off;'
