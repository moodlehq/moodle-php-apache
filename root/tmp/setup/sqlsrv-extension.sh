#!/usr/bin/env bash

set -e

if [[ ${TARGETPLATFORM} != "linux/amd64" ]]; then
  echo "sqlsrv extension not available for ${TARGETPLATFORM} architecture, skipping"
  exit 0
fi

# Packages for build.
BUILD_PACKAGES="gnupg unixodbc-dev"

# Packages for sqlsrv runtime.
PACKAGES_SQLSRV="unixodbc"

# Note: These dependencies must be installed before installing the Microsoft source because there is a package in there
# which breaks the install.
echo "Installing apt dependencies"
apt-get update
apt-get install -y --no-install-recommends apt-transport-https \
    $BUILD_PACKAGES \
    $PACKAGES_SQLSRV

# Install Microsoft dependencies for sqlsrv
echo "Downloading sqlsrv files"
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# TODO, bookworm should be 12, but the msodbcsql17 package is not available yet, hence using bullseye (11) one.
# (see https://learn.microsoft.com/en-us/answers/questions/1328834/debian-12-public-key-is-not-available)
# Also, with 8.3-RC4, the bullseye (11) has stopped to build ok. So using 10 (buster) for now.
curl https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/mssql-release.list
apt-get update

echo "Install msodbcsql"
ACCEPT_EULA=Y apt-get install -y msodbcsql18

ln -fsv /opt/mssql-tools18/bin/* /usr/bin

# Need 5.11 (or later) for PHP 8.2 support
pecl install sqlsrv-5.11.1
docker-php-ext-enable sqlsrv

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
