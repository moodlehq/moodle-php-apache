FROM php:7.1-apache-stretch

ARG DEBIAN_FRONTEND=noninteractive

# Install the standard PHP extensions.
ADD root/tmp/setup/php-extensions.sh /tmp/setup/
RUN chmod 777 /tmp && chmod +t /tmp && \
    /tmp/setup/php-extensions.sh
ADD nvm-wrapper /usr/local/bin/nvm

# Install the PHP MSSQL Extension.
ADD root/tmp/setup/mssql-extension.sh /tmp/setup/
RUN chmod 777 /tmp && chmod +t /tmp && \
    /tmp/setup/mssql-extension.sh

# Install the PHP OCI8 Extension.
ENV LD_LIBRARY_PATH /usr/local/instantclient
ADD root/tmp/setup/oci8-extension.sh /tmp/setup/
RUN chmod 777 /tmp && chmod +t /tmp && \
    /tmp/setup/oci8-extension.sh

# Set the custom entrypoint.
ADD moodle-php-entrypoint /usr/local/bin/
ENTRYPOINT ["moodle-php-entrypoint"]
CMD ["apache2-foreground"]
