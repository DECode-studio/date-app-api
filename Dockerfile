# --------------------------------------------------------
# ✅ BASE IMAGE: PHP-FPM 8.3
# --------------------------------------------------------
FROM php:8.3-fpm

# ✅ Install system dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    git \
    curl \
    zip \
    unzip \
    libpq-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    nano \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip xml

# ✅ Install Composer (from official image)
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --------------------------------------------------------
# ✅ SET WORKDIR
# --------------------------------------------------------
WORKDIR /var/www

# ✅ Copy all app files
COPY . .

# --------------------------------------------------------
# ✅ Install Laravel dependencies
# --------------------------------------------------------
RUN composer install --no-dev --optimize-autoloader --no-interaction

# --------------------------------------------------------
# ✅ Laravel storage & cache permissions
# --------------------------------------------------------
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
    && chmod -R 777 storage bootstrap/cache

# ✅ Forward Laravel logs to container stdout
RUN ln -sf /dev/stdout storage/logs/laravel.log

# ✅ Clear all Laravel caches (prevent 500)
RUN php artisan config:clear || true \
    && php artisan cache:clear || true \
    && php artisan route:clear || true \
    && php artisan view:clear || true

# ✅ Generate Swagger (optional)
RUN php artisan l5-swagger:generate || true

# --------------------------------------------------------
# ✅ Copy Nginx Config
# --------------------------------------------------------
COPY nginx.conf /etc/nginx/conf.d/default.conf

# --------------------------------------------------------
# ✅ Supervisor Config (PHP-FPM + NGINX)
# --------------------------------------------------------
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# --------------------------------------------------------
# ✅ Expose Nginx port
# --------------------------------------------------------
EXPOSE 8080

# --------------------------------------------------------
# ✅ Start Supervisor (runs PHP-FPM + Nginx)
# --------------------------------------------------------
CMD ["/usr/bin/supervisord", "-n"]
