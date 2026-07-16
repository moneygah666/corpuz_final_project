#!/usr/bin/env bash
set -euo pipefail

echo "Running as: $(id)"

mkdir -p /var/www/html/storage/logs \
         /var/www/html/storage/framework/cache/data \
         /var/www/html/storage/framework/sessions \
         /var/www/html/storage/framework/views \
         /var/www/html/bootstrap/cache

chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

PORT_TO_USE="${PORT:-80}"
sed -i "s/^Listen .*/Listen ${PORT_TO_USE}/" /etc/apache2/ports.conf
sed -i "s/<VirtualHost \*:.*>/<VirtualHost *:${PORT_TO_USE}>/" /etc/apache2/sites-available/000-default.conf

php artisan storage:link || true
php artisan package:discover --ansi || true
php artisan migrate --force || true
php artisan optimize || true

exec apache2-foreground