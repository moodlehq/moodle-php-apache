# moodle-php-apache: A Moodle PHP Environment

A Moodle PHP environment configured for Moodle development based on [Official PHP Images](https://hub.docker.com/_/php/).

### Version

| PHP Version  | Variant | Tags             | Status |
|--------------|---------|------------------|--------|
| PHP 8.2      | Bullseye| 8.2, 8.2-bullseye| [![Test and publish 8.2](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml/badge.svg?branch=8.2-bullseye)](https://github.com/moodlehq/moodle-php-apache/actions/workflows/test_buildx_and_publish.yml)|

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

## Directories
To faciliate testing and easy setup the following directories are created and owned by www-data by default:

* `/var/www/moodledata`
* `/var/www/phpunitdata`
* `/var/www/behatdata`
* `/var/www/behatfaildumps`


## See also
This container is part of a set of containers for Moodle development, see also:

* [moodle-docker](https://github.com/moodlehq/moodle-docker) a docker-composer based set of tools to get Moodle development running with zero configuration
* [moodle-db-mssql](https://github.com/moodlehq/moodle-db-mssql) Microsoft SQL Server for Linux configured for Moodle development
* [moodle-db-oracle](https://github.com/moodlehq/moodle-db-oracle) Oracle XE configured for Moodle development
