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
docker-php-ext-install -j$(nproc) \
    intl \
    mysqli \
    opcache \
    pgsql \
    soap \
    xsl \
    xmlrpc

# GD.
docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
docker-php-ext-install -j$(nproc) gd

# LDAP.
docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
docker-php-ext-install -j$(nproc) ldap

# Memcached, MongoDB, Redis, APCu, igbinary.
pecl install memcached mongodb redis apcu igbinary uuid
docker-php-ext-enable memcached mongodb redis apcu igbinary uuid

# ZIP
docker-php-ext-configure zip --with-zip
docker-php-ext-install zip

echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini

# Install custom solr extension. Last release (2.4.0) is not working at all
# with php72 and php73 and upstream has not either! Solution:
#   - current master (as of 21th May 2019):
#     https://github.com/php/pecl-search_engine-solr/commit/98a8bf540bcb4e9b2e1378cce2f3a9bf6cd772b8
#   - this patch, applied already upstream:
#     https://github.com/php/pecl-search_engine-solr/commit/744e32915d5989101267ed2c84a407c582dc6f31
# So, following the experience with Macports, and https://bugs.php.net/bug.php?id=75631
# we are going to try 2.4.0 release + macports patch. Old, but working right now.
# References:
#   - https://github.com/moodlehq/moodle-php-apache/issues/16 (part of the php72 image discussion)
#   - https://github.com/moodlehq/moodle-php-apache/issues/19 (awaiting for a better solution)
/tmp/setup/solr-extension.sh

# Install Microsoft dependencies for sqlsrv.
# (kept apart for clarity, still need to be run here
# before some build packages are deleted)
/tmp/setup/sqlsrv-extension.sh

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
