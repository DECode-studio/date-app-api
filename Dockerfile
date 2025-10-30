FROM php:8.3-fpm

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

ENV APP_NAME=$APP_NAME
ENV APP_ENV=$APP_ENV
ENV APP_KEY=$APP_KEY
ENV APP_DEBUG=$APP_DEBUG
ENV APP_URL=$APP_URL

ENV DB_CONNECTION=$DB_CONNECTION
ENV DB_HOST=$DB_HOST
ENV DB_PORT=$DB_PORT
ENV DB_DATABASE=$DB_DATABASE
ENV DB_USERNAME=$DB_USERNAME
ENV DB_PASSWORD=$DB_PASSWORD

ENV LOG_CHANNEL=$LOG_CHANNEL
ENV LOG_LEVEL=$LOG_LEVEL
ENV SESSION_DRIVER=$SESSION_DRIVER
ENV CACHE_STORE=$CACHE_STORE
ENV QUEUE_CONNECTION=$QUEUE_CONNECTION
ENV FILESYSTEM_DISK=$FILESYSTEM_DISK


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
