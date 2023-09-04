#!/usr/bin/env bash
  
set -e

# Debian buster (10) haven't got the arm64 packages, it seems, see:
# - buster: https://packages.microsoft.com/debian/10/prod/pool/main/m/msodbcsql18/
# So we won't build the extension for buster (10) images on arm64.
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
curl https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/mssql-release.list
apt-get update

echo "Install msodbcsql"
ACCEPT_EULA=Y apt-get install -y msodbcsql18

ln -fsv /opt/mssql-tools/bin/* /usr/bin

# Need 5.9 (or later) for PHP 8.0 support
pecl install sqlsrv-5.11.0
docker-php-ext-enable sqlsrv

# Keep our image size down..
pecl clear-cache
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
