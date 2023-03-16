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
# TODO, bullseye should be 11, but the msodbcsql17 package is not available yet, hence using buster (10) one.
curl https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/mssql-release.list
apt-get update

echo "Install msodbcsql"
ACCEPT_EULA=Y apt-get install -y msodbcsql17

ln -fsv /opt/mssql-tools/bin/* /usr/bin

# Need 5.10.1 (or later) for PHP 8.2 support
pecl install sqlsrv-5.10.1
docker-php-ext-enable sqlsrv

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
