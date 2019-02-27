FROM php:7.1-apache-stretch

ARG DEBIAN_FRONTEND=noninteractive

# Install NVM and the current (as of 26/02/2019) LTS version of Node.
ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION lts/carbon
RUN mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash && \
    . $NVM_DIR/nvm.sh && nvm install $NODE_VERSION && nvm use --delete-prefix $NODE_VERSION

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
