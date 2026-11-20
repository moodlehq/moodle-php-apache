FROM php:8.4-apache-bookworm

# So we can use it anywhere for conditional stuff. Keeping BC with old (non-buildkit, builders)
ARG TARGETPLATFORM
ENV TARGETPLATFORM=${TARGETPLATFORM:-linux/amd64}
RUN echo "Building for ${TARGETPLATFORM}"

# Install some packages that are useful within the images.
RUN apt-get update && apt-get install -y \
    git bc default-mysql-client-core \
&& rm -rf /var/lib/apt/lists/*

# Install pickle as an easier alternative to PECL, that is not
# available any more for PHP 8 and up. Some alternatives searched were:
#  - https://olvlvl.com/2019-06-docker-pecl-without-pecl
#  - https://github.com/FriendsOfPHP/pickle
#  - manually "curl https://pecl.php.net/get/xxxx && tar && docker-php-ext-install xxx"
# Of course, if the images end using some alternative, we'll switch to it. Just right now
# there isn't such an alternative.a
#
# Update 20201126: Finally, see https://github.com/docker-library/php/issues/1087 it seems that pear/pecl
# continues being availbale with php8, so we are going to continue using it. The previous comments as
# left in case we need to find an alternative way to install PECL stuff and there isn't any official.
# For an example of php80-rc5 near complete, using pickle instead of pear/pecl, look to:
# https://github.com/stronk7/moodle-php-apache/tree/8.0-buster-pickle-version

# Generate all the UTF-8 locales.
ARG DEBIAN_FRONTEND=noninteractive
ADD root/tmp/setup/locales-gen.sh /tmp/setup/locales-gen.sh
RUN /tmp/setup/locales-gen.sh

# Setup the required extensions.
ADD root/tmp/setup/php-extensions.sh /tmp/setup/php-extensions.sh
RUN /tmp/setup/php-extensions.sh

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
ADD root/etc /etc
ADD root/system-docker-entrypoint.d/wwwroot.sh /system-docker-entrypoint.d/10-wwwroot.sh

# Fix the original permissions of /tmp, the PHP default upload tmp dir.
RUN chmod 777 /tmp && chmod +t /tmp

# Allow configuration of the Apache DocumentRoot via environment variable.
# Note: Do not specify a default value here, as it will be set in the
#       `wwwroot.sh` script, which will be run before the Apache server starts.
#       This allows the user to override the default value by setting the
#       `APACHE_DOCUMENT_ROOT` environment variable when running the container.

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

CMD ["apache2-foreground"]
ENTRYPOINT ["moodle-docker-php-entrypoint"]
