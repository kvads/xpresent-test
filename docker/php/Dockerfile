FROM php:8.2.3-fpm

ARG WORKDIR=/var/www/html
ENV DOCUMENT_ROOT=${WORKDIR}
ARG GROUP_ID=1000
ARG USER_ID=1000
ENV USER_NAME=www-data
ENV GROUP_NAME=www-data

RUN --mount=type=cache,target=/var/cache/apt \
    apt-get update && apt-get install -y \
        git curl zip unzip \
        libpng-dev libonig-dev libxml2-dev libpq-dev libzip-dev \
        libwebp-dev libjpeg-dev \
        libfreetype6-dev \
        zlib1g-dev \
        iproute2 && \
    docker-php-ext-install \
        opcache mbstring exif pcntl bcmath zip sockets \
        pdo pdo_pgsql pgsql && \
    docker-php-ext-configure pgsql --with-pgsql=/usr/local/pgsql && \
    docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp && \
    docker-php-ext-install gd && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer

WORKDIR $WORKDIR

COPY ./docker/common/php/conf.d $PHP_INI_DIR/conf.d
COPY ./docker/common/php/php.conf /usr/local/etc/php-fpm.d/www.conf

COPY ./docker/php/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh && ln -s /usr/local/bin/entrypoint.sh /

ENTRYPOINT ["entrypoint.sh"]

RUN usermod -u ${USER_ID} ${USER_NAME} \
    && groupmod -g ${USER_ID} ${GROUP_NAME} \
    && chown -R ${USER_NAME}:${GROUP_NAME} /var/www \
    && chown -R ${USER_NAME}:${GROUP_NAME} /var/log/ \
    && chown -R ${USER_NAME}:${GROUP_NAME} $PHP_INI_DIR/conf.d/ \
    && chown -R ${USER_NAME}:${GROUP_NAME} /tmp

EXPOSE 9000

