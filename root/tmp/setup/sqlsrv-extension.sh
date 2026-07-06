#!/usr/bin/env bash

set -e

# Packages for build.
BUILD_PACKAGES="unixodbc-dev"

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
echo "Downloading PMC (packages.microsoft.com) files"
curl -sSL -O https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update

echo "Install msodbcsql and tools"
ACCEPT_EULA=Y apt-get install -y msodbcsql18 mssql-tools18

ln -fsv /opt/mssql-tools18/bin/* /usr/bin

# Need 5.13 (or later) for PHP 8.5 support
pecl install sqlsrv-5.13.0
docker-php-ext-enable sqlsrv

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm packages-microsoft-prod.deb
rm -rf /var/lib/apt/lists/*
