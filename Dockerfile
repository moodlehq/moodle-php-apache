FROM php:7.3-apache-buster

ADD root/ /
# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /tmp && chmod +t /tmp

# Setup the required extensions.
ARG DEBIAN_FRONTEND=noninteractive
RUN /tmp/setup/php-extensions.sh
RUN /tmp/setup/oci8-extension.sh
ENV LD_LIBRARY_PATH /usr/local/instantclient

RUN mkdir /var/www/moodledata && chown www-data /var/www/moodledata && \
    mkdir /var/www/phpunitdata && chown www-data /var/www/phpunitdata && \
    mkdir /var/www/behatdata && chown www-data /var/www/behatdata && \
    mkdir /var/www/behatfaildumps && chown www-data /var/www/behatfaildumps

ARG XDEBUG=0
ARG XDEBUG_VERSION=2.7.2
ARG XDEBUG_PORT=9000
ARG XDEBUG_REMOTE_HOST=docker.for.mac.host.internal
RUN /tmp/setup/xdebug-extension.sh \
    -d $XDEBUG \
    -v $XDEBUG_VERSION \
    -p $XDEBUG_PORT \
    -h $XDEBUG_REMOTE_HOST
