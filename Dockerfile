FROM php:7.4-apache-buster

# So we can use it anywhere for conditional stuff. Keeping BC with old (non-buildkit, builders)
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN echo "Building for ${TARGETPLATFORM}"

# Install some packages that are useful within the images.
RUN apt-get update && apt-get install -y \
    git bc default-mysql-client-core \
&& rm -rf /var/lib/apt/lists/*

# Generate all the UTF-8 locales.
ARG DEBIAN_FRONTEND=noninteractive
ADD root/tmp/setup/locales-gen.sh /tmp/setup/locales-gen.sh
RUN /tmp/setup/locales-gen.sh

# Setup the required extensions.
ADD root/tmp/setup/php-extensions.sh /tmp/setup/php-extensions.sh
RUN /tmp/setup/php-extensions.sh

# Install Oracle Instantclient
ADD root/tmp/setup/oci8-extension.sh /tmp/setup/oci8-extension.sh
RUN /tmp/setup/oci8-extension.sh
ENV LD_LIBRARY_PATH /usr/local/instantclient

# Install Microsoft sqlsrv.
ADD root/tmp/setup/sqlsrv-extension.sh /tmp/setup/sqlsrv-extension.sh
RUN /tmp/setup/sqlsrv-extension.sh

RUN mkdir /var/www/moodledata && chown www-data /var/www/moodledata && \
    mkdir /var/www/phpunitdata && chown www-data /var/www/phpunitdata && \
    mkdir /var/www/behatdata && chown www-data /var/www/behatdata && \
    mkdir /var/www/behatfaildumps && chown www-data /var/www/behatfaildumps && \
    mkdir /var/www/.npm && chown www-data /var/www/.npm && \
    mkdir /var/www/.nvm && chown www-data /var/www/.nvm

ADD root/usr /usr

# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /tmp && chmod +t /tmp

CMD ["apache2-foreground"]
ENTRYPOINT ["moodle-docker-php-entrypoint"]
