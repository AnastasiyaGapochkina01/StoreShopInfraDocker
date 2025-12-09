FROM php:8.3-fpm-bookworm

ARG UID=33
ARG GID=33
ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NOWARNINGS="yes"

COPY www.conf /usr/local/etc/php-fpm.d/www.conf
COPY php.ini /usr/local/etc/php/conf.d/magento.ini
RUN apt-get update && apt-get install -y \
    git curl unzip gnupg2 libpq-dev \
    libicu-dev libxml2-dev libonig-dev \
    libzip-dev libjpeg62-turbo-dev libpng-dev libfreetype6-dev \
    libxslt1-dev libssl-dev libmagickwand-dev \
    libcurl4-openssl-dev pkg-config iproute2 procps \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --with-freetype \
    --with-jpeg

RUN docker-php-ext-install -j$(nproc) \
    bcmath intl pdo_mysql soap zip gd xsl sockets opcache

# ftp
RUN docker-php-ext-configure ftp --with-openssl-dir=/usr \
    && docker-php-ext-install ftp

# Imagick (часто требуется модулями)
RUN pecl install imagick && \
    docker-php-ext-enable imagick

RUN curl -sS https://getcomposer.org/installer | \
  php -- --install-dir=/usr/local/bin --filename=composer

RUN mkdir -p /var/www/.config/composer
WORKDIR /var/www/html
RUN groupmod -g ${GID} www-data && usermod -u ${UID} www-data
RUN chown -R www-data:www-data /var/www

CMD ["php-fpm"]
