#!/bin/bash

echo "🔧 Generating .env from Railway environment..."
printenv | grep -E '^(APP_|DB_|MAIL_|AWS_|LOG_|SESSION_|REDIS_)' > /var/www/.env
echo "✅ .env created successfully!"

echo "🔧 Preparing storage directory..."
mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/{cache,sessions,views}

# ✅ FIX UTAMA – buat ulang file tiap runtime
touch /var/www/storage/logs/laravel.log
chmod -R 777 /var/www/storage

# ✅ Forward log ke stdout (HARUS SESUDAH touch)
ln -sf /dev/stdout /var/www/storage/logs/laravel.log

echo "🎯 Running Laravel cache clean..."
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

echo "✅ Laravel ready. Starting Supervisor..."
exec /usr/bin/supervisord -n
