# -----------------------
# Base Stage
# -----------------------
FROM php:8.3-fpm AS base

# Install dependencies
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpq-dev libonig-dev libxml2-dev libzip-dev nano \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip xml

# Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

# Copy app (except vendor)
COPY . .

# Install dependencies
RUN composer install --no-dev --optimize-autoloader

# Laravel permissions
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
    && chmod -R 777 storage bootstrap/cache

# Generate swagger docs if needed
RUN php artisan l5-swagger:generate || true

# -----------------------
# Production Stage (Nginx + PHP-FPM)
# -----------------------
FROM nginx:stable AS production

WORKDIR /var/www

# Copy app from base stage
COPY --from=base /var/www /var/www

# Copy nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
