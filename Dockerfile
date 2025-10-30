# --------------------------------------------------------
# ✅ BASE IMAGE: PHP 8.3 FPM
# --------------------------------------------------------
FROM php:8.3-fpm

# --------------------------------------------------------
# ✅ Install system dependencies
# --------------------------------------------------------
RUN apt-get update && apt-get install -y \
    nginx \
    supervisor \
    git \
    curl \
    zip \
    unzip \
    nano \
    libpq-dev \
    libzip-dev \
    libonig-dev \
    libxml2-dev \
    && docker-php-ext-install pdo pdo_pgsql mbstring zip xml

# --------------------------------------------------------
# ✅ Composer (copy from composer official image)
# --------------------------------------------------------
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# --------------------------------------------------------
# ✅ Working directory
# --------------------------------------------------------
WORKDIR /var/www

# Copy app source
COPY . .

# --------------------------------------------------------
# ✅ Receive ENV (BUILD-TIME) from railway.toml
# --------------------------------------------------------
ARG APP_NAME
ARG APP_ENV
ARG APP_KEY
ARG APP_DEBUG
ARG APP_URL

ARG DB_CONNECTION
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD

ARG LOG_CHANNEL
ARG LOG_LEVEL

ARG SESSION_DRIVER
ARG CACHE_STORE
ARG QUEUE_CONNECTION
ARG FILESYSTEM_DISK

# --------------------------------------------------------
# ✅ Write .env file (AT BUILD TIME)
# --------------------------------------------------------
RUN echo "APP_NAME=${APP_NAME}" > .env && \
    echo "APP_ENV=${APP_ENV}" >> .env && \
    echo "APP_KEY=${APP_KEY}" >> .env && \
    echo "APP_DEBUG=${APP_DEBUG}" >> .env && \
    echo "APP_URL=${APP_URL}" >> .env && \
    echo "" >> .env && \
    echo "DB_CONNECTION=${DB_CONNECTION}" >> .env && \
    echo "DB_HOST=${DB_HOST}" >> .env && \
    echo "DB_PORT=${DB_PORT}" >> .env && \
    echo "DB_DATABASE=${DB_DATABASE}" >> .env && \
    echo "DB_USERNAME=${DB_USERNAME}" >> .env && \
    echo "DB_PASSWORD=${DB_PASSWORD}" >> .env && \
    echo "" >> .env && \
    echo "LOG_CHANNEL=${LOG_CHANNEL}" >> .env && \
    echo "LOG_LEVEL=${LOG_LEVEL}" >> .env && \
    echo "" >> .env && \
    echo "SESSION_DRIVER=${SESSION_DRIVER}" >> .env && \
    echo "CACHE_STORE=${CACHE_STORE}" >> .env && \
    echo "QUEUE_CONNECTION=${QUEUE_CONNECTION}" >> .env && \
    echo "FILESYSTEM_DISK=${FILESYSTEM_DISK}" >> .env

RUN cat .env

# --------------------------------------------------------
# ✅ Install Laravel dependencies
# --------------------------------------------------------
RUN composer install --optimize-autoloader --no-dev --no-interaction

# --------------------------------------------------------
# ✅ Prepare Laravel storage
# --------------------------------------------------------
RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs && \
    touch storage/logs/laravel.log && \
    chmod -R 777 storage bootstrap/cache

# --------------------------------------------------------
# ✅ Clear Laravel cache (with build-time .env)
# --------------------------------------------------------
RUN php artisan config:clear || true && \
    php artisan cache:clear || true && \
    php artisan route:clear || true && \
    php artisan view:clear || true

# --------------------------------------------------------
# ✅ Swagger Documentation (Optional)
# --------------------------------------------------------
RUN php artisan l5-swagger:generate || true

# --------------------------------------------------------
# ✅ Copy Config for Nginx + Supervisor
# --------------------------------------------------------
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

# --------------------------------------------------------
# ✅ Expose port
# --------------------------------------------------------
EXPOSE 8080

# --------------------------------------------------------
# ✅ Start Supervisor (Runs Nginx + PHP-FPM)
# --------------------------------------------------------
CMD ["/usr/bin/supervisord", "-n"]
