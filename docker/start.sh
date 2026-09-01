#!/bin/sh
set -e

# Sevalla provides the web port through $PORT. Use 80 as a local fallback.
PORT="${PORT:-80}"

# Nginx must listen on the same port Sevalla routes to.
sed -i "s/listen 80;/listen ${PORT};/" /etc/nginx/conf.d/default.conf

# Let the official WordPress entrypoint initialize wp-config.php,
# permissions, and the WordPress files on the persistent volume.
/usr/local/bin/docker-entrypoint.sh php-fpm -D

# Configure Redis only when Sevalla supplies Redis connection variables.
# Never write the Redis password into the image or repository.
WP_CONFIG="/var/www/html/wp-config.php"
if [ -f "$WP_CONFIG" ] && [ -n "${REDIS_HOST:-}" ]; then
    if ! grep -q "WP_REDIS_HOST" "$WP_CONFIG"; then
        sed -i "/\/\* That's all, stop editing! Happy publishing. \*\//i\\
define('WP_REDIS_HOST', getenv('REDIS_HOST'));\\
define('WP_REDIS_PORT', (int) (getenv('REDIS_PORT') ?: 6379));\\
define('WP_REDIS_PASSWORD', getenv('REDIS_PASSWORD') ?: '');\\
define('WP_REDIS_DATABASE', 0);\\
define('WP_REDIS_PREFIX', 'wp_');\\
" "$WP_CONFIG"
    fi
fi

# Nginx stays in the foreground so Sevalla can monitor the web process.
exec nginx -g 'daemon off;'
