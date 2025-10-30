# --------------------------------------------------------
# ✅ BASE IMAGE: PHP-FPM 8.3
# --------------------------------------------------------
FROM php:8.3-fpm

# ✅ System dependencies
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

# ✅ Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --------------------------------------------------------
# ✅ Application source
# --------------------------------------------------------
WORKDIR /var/www
COPY . .

# --------------------------------------------------------
# ✅ Install Laravel dependencies
# --------------------------------------------------------
RUN composer install --no-dev --optimize-autoloader --no-interaction

# --------------------------------------------------------
# ✅ Storage permissions + LOG FIX
# --------------------------------------------------------
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
    && touch storage/logs/laravel.log \
    && chmod -R 777 storage bootstrap/cache storage/logs

# ✅ Forward logs to stdout (AFTER file exists)
RUN ln -sf /dev/stdout storage/logs/laravel.log

# ✅ Swagger
RUN php artisan l5-swagger:generate || true

# --------------------------------------------------------
# ✅ Nginx + Supervisor configs
# --------------------------------------------------------
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# --------------------------------------------------------
# ✅ ENTRYPOINT for runtime .env generation
# --------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

# --------------------------------------------------------
# ✅ Expose port for Nginx
# --------------------------------------------------------
EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
