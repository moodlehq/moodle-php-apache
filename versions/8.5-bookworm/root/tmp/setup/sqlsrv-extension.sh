#!/usr/bin/env bash

set -e

if [[ ${TARGETPLATFORM} != "linux/amd64" ]]; then
  echo "sqlsrv extension not available for ${TARGETPLATFORM} architecture, skipping"
  exit 0
fi

# Packages for build.
BUILD_PACKAGES="gnupg libtool unixodbc-dev"

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
# We have to stay with 17 because 18 encrypts the connections by default and that breaks ADOdb/2nd connection
# tests. Only when https://tracker.moodle.org/browse/MDL-77678 is fixed, we can move to odbc18.
ACCEPT_EULA=Y apt-get install -y msodbcsql17

ln -fsv /opt/mssql-tools/bin/* /usr/bin

# Use Microsoft's release archive to avoid PIE's GitHub API rate limit.
export HOME=/tmp/pie-build
mkdir -p "$HOME" /tmp/pie-sqlsrv
curl -fsSL https://github.com/microsoft/msphpsql_sqlsrv/releases/download/v5.14.0/sqlsrv-v5.14.0.tgz \
    | tar -xz -C /tmp/pie-sqlsrv
cat > /tmp/pie-sqlsrv/composer.json <<'EOF'
{"name":"microsoft/sqlsrv","version":"5.14.0","type":"php-ext","php-ext":{"extension-name":"sqlsrv"}}
EOF
pie repository:add path /tmp/pie-sqlsrv
pie install --no-interaction --no-cache 'microsoft/sqlsrv:5.14.0'
rm -rf /tmp/pie-sqlsrv
rm -rf /tmp/pie-build

# Keep our image size down..
apt-get remove --purge -y $BUILD_PACKAGES
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
