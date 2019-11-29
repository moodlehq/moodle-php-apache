#!/usr/bin/env bash
  
set -e

# Install Microsoft dependencies for sqlsrv
# Debian 9 requires ODBC driver 17, still not package available in repos, so followed this
# https://github.com/Microsoft/msphpsql/wiki/Install-and-configuration#user-content-odbc-17-linux-installation
echo "Downloading sqlsrv files"
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/debian/9/prod.list -o /etc/apt/sources.list.d/mssql-release.list
apt-get update

echo "Install msodbcsql"
ACCEPT_EULA=Y apt-get install -y msodbcsql17

ln -fsv /opt/mssql-tools/bin/* /usr/bin

# Need 5.7.0preview (or later) for PHP 7.4 support
pecl install sqlsrv-5.7.0preview
docker-php-ext-enable sqlsrv
