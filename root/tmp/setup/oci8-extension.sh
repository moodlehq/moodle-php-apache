#!/usr/bin/env bash

set -e

echo "Downloading oracle files"
curl https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip \
    -o /tmp/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip
curl https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip \
    -o /tmp/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip
curl https://download.oracle.com/otn_software/linux/instantclient/19600/instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip \
    -o /tmp/instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip

unzip /tmp/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip -d /usr/local/
rm /tmp/instantclient-basic-linux.x64-19.6.0.0.0dbru.zip
unzip /tmp/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip -d /usr/local/
rm /tmp/instantclient-sdk-linux.x64-19.6.0.0.0dbru.zip
unzip /tmp/instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip -d /usr/local/
rm /tmp/instantclient-sqlplus-linux.x64-19.6.0.0.0dbru.zip

ln -s /usr/local/instantclient_19_6 /usr/local/instantclient
ln -s /usr/local/instantclient/sqlplus /usr/bin/sqlplus

echo "--with-oci8=instantclient,/usr/local/instantclient" > oci8_options
pickle install oci8 --with-configure-options oci8_options && docker-php-ext-enable oci8
echo 'oci8.statement_cache_size = 0' >> /usr/local/etc/php/conf.d/docker-php-ext-oci8.ini
rm oci8_options
