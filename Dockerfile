FROM php:7.0-apache-jessie

ADD root/ /
# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /tmp && chmod +t /tmp
# Remove jessie-updates from sources (https://lists.debian.org/debian-devel-announce/2019/03/msg00006.html)
RUN sed -i '/jessie-updates/d' /etc/apt/sources.list
# Setup the required extensions.
RUN /tmp/setup/php-extensions.sh
RUN /tmp/setup/oci8-extension.sh

RUN mkdir /var/www/moodledata && chown www-data /var/www/moodledata && \
    mkdir /var/www/phpunitdata && chown www-data /var/www/phpunitdata && \
    mkdir /var/www/behatdata && chown www-data /var/www/behatdata && \
    mkdir /var/www/behatfaildumps && chown www-data /var/www/behatfaildumps
