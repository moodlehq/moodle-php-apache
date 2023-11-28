# moodle-php-apache: A Moodle PHP Environment

A Moodle PHP environment configured for Moodle development based on [Official PHP Images](https://hub.docker.com/_/php/).

### Versions

| PHP Version  | Variant | Tags             | Status | Notes |
|--------------|---------|------------------|--------|-------|
| PHP 8.3      | Bookworm| dev| [![Test and publish 8.3](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=master)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)||
| PHP 8.3      | Bookworm | 8.3, 8.3-bookworm| [![Test and publish 8.3](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.3-bookworm)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|
| PHP 8.2      | Bookworm | 8.2, 8.2-bookworm| [![Test and publish 8.2](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.2-bookworm)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|
| PHP 8.1      | Bookworm | 8.1, 8.1-bookworm | [![Test and publish 8.1](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.1-bookworm)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|
| PHP 8.3      | Bullseye| 8.3-bullseye| [![Test and publish 8.3](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.3-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|
| PHP 8.2      | Bullseye| 8.2-bullseye| [![Test and publish 8.2](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.2-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|
| PHP 8.1      | Bullseye| 8.1-bullseye| [![Test and publish 8.1](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.1-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|
| PHP 8.0      | Bullseye| 8.0, 8.0-bullseye| [![Test and publish 8.0](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.0-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|PHP 8.0 EOL|
| PHP 7.4      | Bullseye| 7.4, 7.4-bullseye| [![Test and publish 7.4](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=7.4-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|PHP 7.4 EOL|
| PHP 8.2      | Buster  | 8.2-buster       | [![Test and publish 8.2](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.2-buster)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|Not updated since 8.2.7, June 2023|
| PHP 8.1      | Buster  | 8.1-buster       | [![Test and publish 8.1](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.1-buster)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|Not updated since 8.1.20, June 2023|
| PHP 8.0      | Buster  | 8.0-buster       | [![Test and publish 8.0](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.0-buster)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|PHP 8.0 EOL|
| PHP 7.4      | Buster  | 7.4-buster       | [![Test and publish 7.4](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=7.4-buster)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|PHP 7.4 EOL|
| PHP 7.3      | Buster  | 7.3, 7.3-buster  | [![Test and publish 7.3](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=7.3-buster)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|PHP 7.3 EOL|
| PHP 7.2      | Buster  | 7.2, 7.2-buster  | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.2-buster)](https://travis-ci.com/moodlehq/moodle-php-apache)|PHP 7.2 EOL|
| PHP 7.1      | Buster  | 7.1, 7.1-buster  | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.1-buster)](https://travis-ci.com/moodlehq/moodle-php-apache)|PHP 7.1 EOL|
| PHP 7.3      | Stretch | 7.3-stretch      | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.3-stretch)](https://travis-ci.com/moodlehq/moodle-php-apache)|Stretch and PHP 7.3 EOL|
| PHP 7.2      | Stretch | 7.2-stretch      | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.2-stretch)](https://travis-ci.com/moodlehq/moodle-php-apache)|Stretch and PHP 7.2 EOL|
| PHP 7.1      | Stretch | 7.1-stretch      | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.1-stretch)](https://travis-ci.com/moodlehq/moodle-php-apache)|Stretch and PHP 7.1 EOL|
| PHP 7.0      | Stretch | 7.0, 7.0-stretch | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.0-stretch)](https://travis-ci.com/moodlehq/moodle-php-apache)|Stretch and PHP 7.0 EOL|
| PHP 5.6      | Stretch | 5.6, 5.6-stretch | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=5.6-stretch)](https://travis-ci.com/moodlehq/moodle-php-apache)|Stretch and PHP 5.6 EOL|
| PHP 7.1      | Jessie  | 7.1-jessie       | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.1-jessie)](https://travis-ci.com/moodlehq/moodle-php-apache)|Jessie and PHP 7.1 EOL|
| PHP 7.0      | Jessie  | 7.0-jessie       | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=7.0-jessie)](https://travis-ci.com/moodlehq/moodle-php-apache)|Jessie and PHP 7.0 EOL|
| PHP 5.6      | Jessie  | 5.6-jessie       | [![Build Status](https://travis-ci.com/moodlehq/moodle-php-apache.svg?branch=5.6-jessie)](https://travis-ci.com/moodlehq/moodle-php-apache)|Jessie and PHP 5.6 EOL|

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

The following extensions are included as standard:

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
