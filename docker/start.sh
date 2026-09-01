#!/bin/sh
set -e

# Let the official WordPress entrypoint initialize wp-config.php,
# permissions, and the WordPress files on the persistent volume.
/usr/local/bin/docker-entrypoint.sh php-fpm -D

# Nginx stays in the foreground so Sevalla can monitor the web process.
exec nginx -g 'daemon off;'
