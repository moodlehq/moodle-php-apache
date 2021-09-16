#!/usr/bin/env bash

set -e

echo "Installing apt dependencies"

# Build packages will be added during the build, but will be removed at the end.
BUILD_PACKAGES="gettext gnupg libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev \
  libldap2-dev libmariadbclient-dev libmemcached-dev libpng-dev libpq-dev libxml2-dev libxslt-dev \
  unixodbc-dev uuid-dev"

# Packages for Postgres.
PACKAGES_POSTGRES="libpq5"

# Packages for MariaDB and MySQL.
PACKAGES_MYMARIA="libmariadb3"

# Packages for other Moodle runtime dependenices.
PACKAGES_RUNTIME="ghostscript libaio1 libcurl4 libgss3 libicu63 libmcrypt-dev libxml2 libxslt1.1 \
  libzip-dev locales sassc unixodbc unzip zip"

# Packages for Memcached.
PACKAGES_MEMCACHED="libmemcached11 libmemcachedutil2"

# Packages for LDAP.
PACKAGES_LDAP="libldap-2.4-2"

apt-get update
apt-get install -y --no-install-recommends apt-transport-https \
    $BUILD_PACKAGES \
    $PACKAGES_POSTGRES \
    $PACKAGES_MYMARIA \
    $PACKAGES_RUNTIME \
    $PACKAGES_MEMCACHED \
    $PACKAGES_LDAP

# Generate the locales configuration fo rboth Australia, and the US.
echo 'Generating locales..'
echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen
echo 'en_AU.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen

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

# APCu, igbinary, Memcached, Redis, Solr, uuid
pecl install apcu igbinary memcached redis solr uuid pcov
docker-php-ext-enable apcu igbinary memcached redis solr uuid pcov
#TODO:
#  - mongodb failing as of 2021-09-19. Add it back once working.
#  - xmlrpc failing as of 2021-09-19. Add it back once working.

echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

echo "pcov.enabled=0" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini
echo "pcov.exclude='~\/(tests|coverage|vendor|node_modules)\/~'" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini
echo "pcov.directory=." >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini
echo "pcov.initial.files=1024" >> /usr/local/etc/php/conf.d/docker-php-ext-pcov.ini

# Install Microsoft dependencies for sqlsrv.
# (kept apart for clarity, still need to be run here
# before some build packages are deleted)
if [[ ${TARGETPLATFORM} == "linux/amd64" ]]; then
    /tmp/setup/sqlsrv-extension.sh
else
    echo "sqlsrv extension not available for ${TARGETPLATFORM} architecture, skipping"
fi

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
