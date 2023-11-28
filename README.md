# moodle-php-apache: A Moodle PHP Environment

A Moodle PHP environment configured for Moodle development based on [Official PHP Images](https://hub.docker.com/_/php/).

### Version

| PHP Version  | Variant | Tags             | Status |
|--------------|---------|------------------|--------|
| PHP 8.2      | Bullseye| 8.2-bullseye| [![Test and publish 8.2](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.2-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|

For a complete list of supported versions, look to the [master README](https://github.com/moodlehq/moodle-php-apache/tree/master).

## Example usage
The following command will expose the current working directory on port 8080:
```bash
$ docker run --name web0 -p 8080:80  -v $PWD:/var/www/html moodlehq/moodle-php-apache:7.1
```

## Features
* Preconfigured with all php extensions required for Moodle development and all database drivers
* Serves wwroot configured at /var/www/html/
* For PHP 7.3 and up, both `linux/amd64` and `linux/arm64` images are being built. Note that `linux/arm64` doesn't support the sqlsrv and oci extensions yet. Other than that, both architectures work exactly the same.
* Verified by [automated tests](https://travis-ci.com/moodlehq/moodle-php-apache).
* Autobuilt from GHA, on push.
* Support for entrypoint scripts and PHP Configuration
* Many common extensions available

## Directories
To facilitate testing and easy setup the following directories are created and owned by www-data by default:

* `/var/www/moodledata`
* `/var/www/phpunitdata`
* `/var/www/behatdata`
* `/var/www/behatfaildumps`

## Initialisation scripts

If you would like to do additional initialization, you can add one or more `*.sh`, or `*.ini`  scripts under `/docker-entrypoint.d` (creating the directory if necessary). When the entrypoint script is called, it will run any executable `*.sh` script, source any non-executable `*.sh` scripts found in that directory, and will copy any `*.ini` scripts into the PHP Configuration directory (`/usr/local/etc/php/conf.d`).

For example, to configure PHP to support a higher `upload_max_filesize` option you might add the following to a `config/10-uploads.ini` file:

```
; Specify a max filesize of 200M for uploads.
upload_max_filesize = 200M
post_max_size = 210M
```

When starting your container you could do so passing in the config directory:

```
docker run \
    --name web0 \
    -p 8080:80 \
    -v $PWD/moodle:/var/www/html
    -v $PWD/config:/docker-entrypoint.d \
    moodle-php-apache:latest
```

These initialization files will be executed in sorted name order as defined by the current locale, which defaults to en_US.utf8.

## PHP Configuration

As a lightweight alternative to a full PHP configuration file, you can specify a set of prefixed environment variables when starting your container with these variables turned into ini-format configuration.

Any environment variable whose name is prefixed with `PHP_INI-` will have the prefix removed, and will be added to a new ini file before the main command starts.

```
docker run \
    --name web0 \
    -p 8080:80 \
    -v $PWD/moodle:/var/www/html
    -e PHP_INI-upload_max_filesize=200M \
    -e PHP_INI-post_max_size=210M \
    moodle-php-apache:latest
```

## Extensions

The following extensions are inluded as standard:

* apcu
* exif
* gd
* igbinary
* intl
* ldap
* memcached
* mysqli
* oci8
* opcache
* pcov
* pgsql
* redis
* soap
* solr
* sqlsrv
* timezonedb
* uuid
* xdebug
* xhprof
* xmlrpc-beta
* xsl
* zip

All of the above extensions are enabled by default, except for:

* pcov
* xdebug
* xhprof

### Enabling optional extensions

Several extensions are installed, but not enabled. You can enable them easily.

### xdebug

The `xdebug` extension can be enabled by specifying the following environment variable when starting the container:

```bash
PHP_EXTENSION_xdebug=1
```

### xhprof

The `xdebug` extension can be enabled by specifying the following environment variable when starting the container:

```bash
PHP_EXTENSION_xhprof=1
```

#### pcov

The `pcov` extension is typically not used in the web UI, but is widely used for code coverage generation in unit testing.

It can be enabled by specifying the following environment variable when starting the container:

```bash
PHP_INI-pcov.enabled=1
```

## See also

This container is part of a set of containers for Moodle development, see also:

* [moodle-docker](https://github.com/moodlehq/moodle-docker) a docker-composer based set of tools to get Moodle development running with zero configuration
* [moodle-db-mssql](https://github.com/moodlehq/moodle-db-mssql) Microsoft SQL Server for Linux configured for Moodle development
* [moodle-db-oracle](https://github.com/moodlehq/moodle-db-oracle) Oracle XE configured for Moodle development
