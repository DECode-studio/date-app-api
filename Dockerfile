FROM php:8.3-fpm

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

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

ARG APP_NAME
ARG APP_ENV
ARG APP_KEY
ARG APP_DEBUG
ARG APP_URL
ARG APP_LOCALE
ARG APP_FALLBACK_LOCALE
ARG APP_FAKER_LOCALE

ARG DB_CONNECTION
ARG DB_HOST
ARG DB_PORT
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD

ARG LOG_CHANNEL
ARG LOG_STACK
ARG LOG_LEVEL

ARG SESSION_DRIVER
ARG SESSION_LIFETIME
ARG SESSION_ENCRYPT
ARG SESSION_PATH
ARG SESSION_DOMAIN

ARG BROADCAST_CONNECTION
ARG FILESYSTEM_DISK
ARG QUEUE_CONNECTION

ARG CACHE_STORE
ARG CACHE_PREFIX

ARG MEMCACHED_HOST

ARG REDIS_CLIENT
ARG REDIS_HOST
ARG REDIS_PASSWORD
ARG REDIS_PORT

ARG MAIL_MAILER
ARG MAIL_SCHEME
ARG MAIL_HOST
ARG MAIL_PORT
ARG MAIL_USERNAME
ARG MAIL_PASSWORD
ARG MAIL_FROM_ADDRESS
ARG MAIL_FROM_NAME

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_DEFAULT_REGION
ARG AWS_BUCKET
ARG AWS_USE_PATH_STYLE_ENDPOINT

RUN echo "APP_NAME=${APP_NAME}" > .env && \
    echo "APP_ENV=${APP_ENV}" >> .env && \
    echo "APP_KEY=${APP_KEY}" >> .env && \
    echo "APP_DEBUG=${APP_DEBUG}" >> .env && \
    echo "APP_URL=${APP_URL}" >> .env && \
    echo "APP_LOCALE=${APP_LOCALE}" >> .env && \
    echo "APP_FALLBACK_LOCALE=${APP_FALLBACK_LOCALE}" >> .env && \
    echo "APP_FAKER_LOCALE=${APP_FAKER_LOCALE}" >> .env && \
    echo "" >> .env && \
    echo "DB_CONNECTION=${DB_CONNECTION}" >> .env && \
    echo "DB_HOST=${DB_HOST}" >> .env && \
    echo "DB_PORT=${DB_PORT}" >> .env && \
    echo "DB_DATABASE=${DB_DATABASE}" >> .env && \
    echo "DB_USERNAME=${DB_USERNAME}" >> .env && \
    echo "DB_PASSWORD=${DB_PASSWORD}" >> .env && \
    echo "" >> .env && \
    echo "LOG_CHANNEL=${LOG_CHANNEL}" >> .env && \
    echo "LOG_STACK=${LOG_STACK}" >> .env && \
    echo "LOG_LEVEL=${LOG_LEVEL}" >> .env && \
    echo "" >> .env && \
    echo "SESSION_DRIVER=${SESSION_DRIVER}" >> .env && \
    echo "SESSION_LIFETIME=${SESSION_LIFETIME}" >> .env && \
    echo "SESSION_ENCRYPT=${SESSION_ENCRYPT}" >> .env && \
    echo "SESSION_PATH=${SESSION_PATH}" >> .env && \
    echo "SESSION_DOMAIN=${SESSION_DOMAIN}" >> .env && \
    echo "" >> .env && \
    echo "BROADCAST_CONNECTION=${BROADCAST_CONNECTION}" >> .env && \
    echo "FILESYSTEM_DISK=${FILESYSTEM_DISK}" >> .env && \
    echo "QUEUE_CONNECTION=${QUEUE_CONNECTION}" >> .env && \
    echo "" >> .env && \
    echo "CACHE_STORE=${CACHE_STORE}" >> .env && \
    echo "CACHE_PREFIX=${CACHE_PREFIX}" >> .env && \
    echo "" >> .env && \
    echo "MEMCACHED_HOST=${MEMCACHED_HOST}" >> .env && \
    echo "" >> .env && \
    echo "REDIS_CLIENT=${REDIS_CLIENT}" >> .env && \
    echo "REDIS_HOST=${REDIS_HOST}" >> .env && \
    echo "REDIS_PASSWORD=${REDIS_PASSWORD}" >> .env && \
    echo "REDIS_PORT=${REDIS_PORT}" >> .env && \
    echo "" >> .env && \
    echo "MAIL_MAILER=${MAIL_MAILER}" >> .env && \
    echo "MAIL_SCHEME=${MAIL_SCHEME}" >> .env && \
    echo "MAIL_HOST=${MAIL_HOST}" >> .env && \
    echo "MAIL_PORT=${MAIL_PORT}" >> .env && \
    echo "MAIL_USERNAME=${MAIL_USERNAME}" >> .env && \
    echo "MAIL_PASSWORD=${MAIL_PASSWORD}" >> .env && \
    echo "MAIL_FROM_ADDRESS=${MAIL_FROM_ADDRESS}" >> .env && \
    echo "MAIL_FROM_NAME=${MAIL_FROM_NAME}" >> .env && \
    echo "" >> .env && \
    echo "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" >> .env && \
    echo "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" >> .env && \
    echo "AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}" >> .env && \
    echo "AWS_BUCKET=${AWS_BUCKET}" >> .env && \
    echo "AWS_USE_PATH_STYLE_ENDPOINT=${AWS_USE_PATH_STYLE_ENDPOINT}" >> .env


RUN composer install --no-dev --optimize-autoloader --no-interaction

RUN mkdir -p storage/framework/{cache,sessions,views} storage/logs \
    && chmod -R 777 storage bootstrap/cache

RUN ln -sf /dev/stdout storage/logs/laravel.log

RUN php artisan config:clear || true \
    && php artisan cache:clear || true \
    && php artisan route:clear || true \
    && php artisan view:clear || true

RUN php artisan l5-swagger:generate || true

COPY nginx.conf /etc/nginx/conf.d/default.conf

COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf

EXPOSE 8080

CMD ["/usr/bin/supervisord", "-n"]
