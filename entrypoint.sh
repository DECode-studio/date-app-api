#!/bin/bash

echo "🔧 Generating .env from Railway environment..."

cat > /var/www/.env <<EOL
APP_NAME=${APP_NAME}
APP_ENV=production
APP_KEY=${APP_KEY}
APP_DEBUG=false
APP_URL=${APP_URL}

LOG_CHANNEL=stack
LOG_LEVEL=debug

DB_CONNECTION=${DB_CONNECTION}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database
FILESYSTEM_DISK=local
EOL

echo "✅ .env created!"
echo "===== GENERATED .env ====="
cat /var/www/.env

echo "🔧 Preparing storage directories..."
mkdir -p /var/www/storage/logs
mkdir -p /var/www/storage/framework/{cache,sessions,views}
touch /var/www/storage/logs/laravel.log
chmod -R 777 /var/www/storage

echo "🎯 Clearing Laravel cache..."
php artisan config:clear || true
php artisan cache:clear || true
php artisan route:clear || true
php artisan view:clear || true

echo "✅ Starting Supervisor..."
exec /usr/bin/supervisord -n
