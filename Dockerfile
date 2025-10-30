# --------------------------------------------------------
# ✅ BASE IMAGE: PHP 8.3 FPM
# --------------------------------------------------------
FROM php:8.3-fpm

# --------------------------------------------------------
# ✅ System dependencies
# --------------------------------------------------------
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

# --------------------------------------------------------
# ✅ Install Composer
# --------------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --------------------------------------------------------
# ✅ App directory
# --------------------------------------------------------
WORKDIR /var/www

# Copy app source
COPY . .

# --------------------------------------------------------
# ✅ Install Laravel dependencies
# --------------------------------------------------------
RUN composer install --no-dev --optimize-autoloader --no-interaction

# --------------------------------------------------------
# ✅ Storage directories + permissions
# --------------------------------------------------------
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
    && touch storage/logs/laravel.log \
    && chmod -R 777 storage bootstrap/cache storage/logs

# --------------------------------------------------------
# ✅ Swagger docs
# --------------------------------------------------------
RUN php artisan l5-swagger:generate || true

# --------------------------------------------------------
# ✅ Copy Nginx & Supervisor configs
# --------------------------------------------------------
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# --------------------------------------------------------
# ✅ Entry Script (create .env from Railway variables)
# --------------------------------------------------------
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
