#!/usr/bin/env bash

set -e

echo "Installing apt dependencies"

# Build packages will be added during the build, but will be removed at the end.
BUILD_PACKAGES="gettext libtool libcurl4-openssl-dev libfreetype6-dev libicu-dev libjpeg62-turbo-dev \
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
    pgsql \
    soap \
    xsl

# GD.
docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
docker-php-ext-install -j$(nproc) gd

# LDAP.
docker-php-ext-configure ldap
docker-php-ext-install -j$(nproc) ldap

# APCu, igbinary, Memcached, PCov, timezonedb, uuid.
export HOME=/tmp/pie-build
mkdir -p "$HOME"
pie install --no-interaction --no-cache 'apcu/apcu:dev-master#fb2c942552a3f5dab7f4dea4afb5cf0831222c57' 'igbinary/igbinary:@RC' \
    'php-memcached/php-memcached:dev-master#0b52d3657140750fa0eddd20cdbfc6edc8fbdadd' \
    'pecl/pcov:dev-issue-php86a2#f04029fa86ae58c6dfff8049de8433669dbf1394' \
    pecl/timezonedb pecl/uuid

# Solr PHP 8.6 support is pending upstream release.
mkdir /tmp/pie-solr
curl -fsSL https://codeload.github.com/bix0r/pecl-search_engine-solr/tar.gz/e2b9b5353624c0e5ad453e57953cb030afb53e05 \
    | tar -xz -C /tmp/pie-solr --strip-components=1
pie repository:add path /tmp/pie-solr
pie install --no-interaction --no-cache 'pecl/solr:@dev'

echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/10-docker-php-ext-apcu.ini

# Install the redis extension enabling igbinary support.
pie install --no-interaction --no-cache \
    'phpredis/phpredis:dev-develop#a6ce1e60b3e81ce3b25174aa5aaefd5590dc64fd' --enable-redis-igbinary

# Install, but do not enable, xdebug and xhprof.
pie install --no-interaction --no-cache --skip-enable-extension 'xdebug/xdebug:^3.6@alpha' wpelevator/xhprof
pie repository:remove /tmp/pie-solr

echo "pcov.enabled=0" >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini
echo "pcov.exclude='~\/(tests|coverage|vendor|node_modules)\/~'" >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini
echo "pcov.directory=." >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini
echo "pcov.initial.files=1024" >> /usr/local/etc/php/conf.d/10-docker-php-ext-pcov.ini

# Keep our image size down..
rm -rf /tmp/pie-solr
rm -rf /tmp/pie-build
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
