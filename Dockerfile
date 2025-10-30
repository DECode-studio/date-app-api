FROM php:8.3-fpm

# Install dependencies
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    git curl zip unzip libpq-dev libonig-dev libxml2-dev libzip-dev nano \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip xml

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

RUN composer install --no-dev --optimize-autoloader

RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
    && chmod -R 777 storage bootstrap/cache

# generate swagger
RUN php artisan l5-swagger:generate || true

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Supervisor config
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
