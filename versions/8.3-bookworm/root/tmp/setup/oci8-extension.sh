#!/usr/bin/env bash

set -e

if [[ ${TARGETPLATFORM} != "linux/amd64" ]]; then
    echo "oracle extension not available for ${TARGETPLATFORM} architecture, skipping"
    exit 0
fi

echo "Downloading oracle files"
curl https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip \
    -o /tmp/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip
curl https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-sdk-linux.x64-21.6.0.0.0dbru.zip \
    -o /tmp/instantclient-sdk-linux.x64-21.6.0.0.0dbru.zip
curl https://download.oracle.com/otn_software/linux/instantclient/216000/instantclient-sqlplus-linux.x64-21.6.0.0.0dbru.zip \
    -o /tmp/instantclient-sqlplus-linux.x64-21.6.0.0.0dbru.zip

unzip /tmp/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip -d /usr/local/
rm /tmp/instantclient-basic-linux.x64-21.6.0.0.0dbru.zip
unzip /tmp/instantclient-sdk-linux.x64-21.6.0.0.0dbru.zip -d /usr/local/
rm /tmp/instantclient-sdk-linux.x64-21.6.0.0.0dbru.zip
unzip /tmp/instantclient-sqlplus-linux.x64-21.6.0.0.0dbru.zip -d /usr/local/
rm /tmp/instantclient-sqlplus-linux.x64-21.6.0.0.0dbru.zip

ln -s /usr/local/instantclient_21_6 /usr/local/instantclient
ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

echo 'instantclient,/usr/local/instantclient' | pecl install oci8
docker-php-ext-enable oci8
echo 'oci8.statement_cache_size = 0' >> /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini
