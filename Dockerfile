# ---- Base PHP-FPM 8.3
FROM php:8.3-fpm

# System deps + PHP extensions
RUN apt-get update && apt-get install -y \
    nginx supervisor git curl zip unzip nano \
    libpq-dev libzip-dev libonig-dev libxml2-dev \
  && docker-php-ext-install pdo pdo_pgsql mbstring zip xml \
  && rm -rf /var/lib/apt/lists/*

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# App
WORKDIR /var/www
COPY . .

# Composer install (no dev)
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Storage perms
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
 && touch storage/logs/laravel.log \
 && chmod -R 777 storage bootstrap/cache

# (Opsional) Swagger generate; aman kalau paket tidak ada
RUN php artisan l5-swagger:generate || true

# Nginx & Supervisor
COPY ./infra/nginx.conf /etc/nginx/conf.d/default.conf
COPY ./infra/supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# Entrypoint ringan: pastikan perms tetap oke pas start
COPY ./infra/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n"]
