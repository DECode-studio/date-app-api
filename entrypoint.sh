#!/bin/bash
set -e

# Pastikan writable (kalau host volume ganti perms)
mkdir -p /var/www/storage/logs /var/www/storage/framework/{cache,sessions,views}
touch /var/www/storage/logs/laravel.log || true
chmod -R 777 /var/www/storage /var/www/bootstrap/cache || true

# Jangan utak-atik .env — kita mount dari host
# (Opsional) bersih-bersih cache agar baca .env terbaru
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

exec "$@"
