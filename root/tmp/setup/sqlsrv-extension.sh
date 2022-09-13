#!/usr/bin/env bash

set -e

# Install Microsoft dependencies for sqlsrv
echo "Downloading sqlsrv files"
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# TODO, bullseye should be 11, but the msodbcsql17 package is not available yet, hence using buster (10) one.
curl https://packages.microsoft.com/config/debian/10/prod.list -o /etc/apt/sources.list.d/mssql-release.list
apt-get update

echo "Install msodbcsql"
ACCEPT_EULA=Y apt-get install -y msodbcsql17

ln -fsv /opt/mssql-tools/bin/* /usr/bin

# Need 5..10.0beta1 (or later) for PHP 8.1 support
pecl install sqlsrv-5.10.1
docker-php-ext-enable sqlsrv
