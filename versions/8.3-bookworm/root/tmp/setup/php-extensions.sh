#!/usr/bin/env bash

set -e

echo "Installing apt dependencies"

# Build packages will be added during the build, but will be removed at the end.
BUILD_PACKAGES="gettext libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev \
  libldap2-dev libmariadb-dev libmemcached-dev libpng-dev libpq-dev libxml2-dev libxslt-dev \
  uuid-dev"

# Packages for Postgres.
PACKAGES_POSTGRES="libpq5"

# Packages for MariaDB and MySQL.
PACKAGES_MYMARIA="libmariadb3"

# Packages for other Moodle runtime dependenices.
PACKAGES_RUNTIME="ghostscript libaio1 libcurl4 libgss3 libicu72 libmcrypt-dev libxml2 libxslt1.1 \
  libzip-dev sassc unzip zip"

# Packages for Memcached.
PACKAGES_MEMCACHED="libmemcached11 libmemcachedutil2"

# Packages for LDAP.
PACKAGES_LDAP="libldap-2.5-0"

apt-get update
apt-get install -y --no-install-recommends apt-transport-https \
    $BUILD_PACKAGES \
    $PACKAGES_POSTGRES \
    $PACKAGES_MYMARIA \
    $PACKAGES_RUNTIME \
    $PACKAGES_MEMCACHED \
    $PACKAGES_LDAP

echo "Installing php extensions"

# ZIP
docker-php-ext-configure zip --with-zip
docker-php-ext-install zip

docker-php-ext-install -j$(nproc) \
    exif \
    intl \
    mysqli \
    opcache \
    pgsql \
    soap \
    xsl

# GD.
docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
docker-php-ext-install -j$(nproc) gd

# LDAP.
docker-php-ext-configure ldap
docker-php-ext-install -j$(nproc) ldap

# APCu, igbinary, Memcached, PCov, Redis, Solr, timezonedb, uuid
pecl install apcu igbinary memcached pcov solr timezonedb uuid
docker-php-ext-enable apcu igbinary memcached pcov solr timezonedb uuid

echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini

# Install the redis extension enabling igbinary support.
pecl install --configureoptions 'enable-redis-igbinary="yes"' redis
docker-php-ext-enable redis

# Install, but do not enable, xdebug and xhprof.
pecl install xdebug xhprof

echo "pcov.enabled=0" >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini
echo "pcov.exclude='~\/(tests|coverage|vendor|node_modules)\/~'" >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini
echo "pcov.directory=." >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini
echo "pcov.initial.files=1024" >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
