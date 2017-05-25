# moodle-php-apache: A Moodle PHP Environment

A Moodle PHP environment configured for Moodle development.

PHP and Apache configured to serve /var/www/html/ based on [Official PHP Images](https://hub.docker.com/_/php/) with php extensions required for all Moodle database drivers and extensions.

# Example usage
The following command will expose the current working directory on port 8080:
```bash
$ docker run --name web0 -p 8080:80  -v $PWD:/var/www/html danpoltawski/moodle-php-apache:7.1
```

# Versions

| PHP Version  | Tag | Status |
|--------------|-----|--------|
| PHP 7.1 | 7.1 | [![Build Status](https://travis-ci.org/danpoltawski/moodle-php-apache.svg?branch=php71)](https://travis-ci.org/danpoltawski/moodle-php-apache)|
| PHP 7.0 | 7.0 | [![Build Status](https://travis-ci.org/danpoltawski/moodle-php-apache.svg?branch=php70)](https://travis-ci.org/danpoltawski/moodle-php-apache)|
|PHP 5.6 | 5.6 | [![Build Status](https://travis-ci.org/danpoltawski/moodle-php-apache.svg?branch=php56)](https://travis-ci.org/danpoltawski/moodle-php-apache)|

# Features

* Preconfigured with all php extensions required for Moodle development and all database drivers
* Serves wwroot configured at /var/www/html/
* Verified by [automated tests](https://travis-ci.org/danpoltawski/moodle-php-apache)
