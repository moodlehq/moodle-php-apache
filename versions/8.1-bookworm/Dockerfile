# Stage 1: PHP 8.1 built from source, with the PHP project's minimal backport for
# the EOL 8.1 branch applied (CVE-2026-109618 / CVE-2026-109619, aka PHP2Shell).
# PHP does not publish a patched php:8.1 image, so this stage is the upstream docker-library/php
# 8.1 bookworm apache Dockerfile (last version, 8.1.34), plus the patch step. Helper scripts
# in php-base/ are copied unchanged from the official php:8.1-apache-bookworm image.
FROM debian:bookworm-slim AS php-base

# prevent Debian's PHP packages from being installed
# https://github.com/docker-library/php/pull/542
RUN set -eux; \
	{ \
		echo 'Package: php*'; \
		echo 'Pin: release *'; \
		echo 'Pin-Priority: -1'; \
	} > /etc/apt/preferences.d/no-debian-php

# dependencies required for running "phpize"
# (see persistent deps below)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkg-config \
		re2c

# persistent / runtime deps
RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		$PHPIZE_DEPS \
		ca-certificates \
		curl \
		xz-utils \
	; \
	rm -rf /var/lib/apt/lists/*

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	chown www-data:www-data /var/www/html; \
	chmod 1777 /var/www/html

ENV APACHE_CONFDIR /etc/apache2
ENV APACHE_ENVVARS $APACHE_CONFDIR/envvars

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends apache2; \
	rm -rf /var/lib/apt/lists/*; \
	\
# generically convert lines like
#   export APACHE_RUN_USER=www-data
# into
#   : ${APACHE_RUN_USER:=www-data}
#   export APACHE_RUN_USER
# so that they can be overridden at runtime ("-e APACHE_RUN_USER=...")
	sed -ri 's/^export ([^=]+)=(.*)$/: ${\1:=\2}\nexport \1/' "$APACHE_ENVVARS"; \
	\
# setup directories and permissions
	. "$APACHE_ENVVARS"; \
	for dir in \
		"$APACHE_LOCK_DIR" \
		"$APACHE_RUN_DIR" \
		"$APACHE_LOG_DIR" \
# https://salsa.debian.org/apache-team/apache2/-/commit/b97ca8714890ead1ba6c095699dde752e8433205
		"$APACHE_RUN_DIR/socks" \
	; do \
		rm -rvf "$dir"; \
		mkdir -p "$dir"; \
		chown "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$dir"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
		chmod 1777 "$dir"; \
	done; \
	\
# delete the "index.html" that installing Apache drops in here
	rm -rvf /var/www/html/*; \
	\
# logs should go to stdout / stderr
	ln -sfT /dev/stderr "$APACHE_LOG_DIR/error.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/access.log"; \
	ln -sfT /dev/stdout "$APACHE_LOG_DIR/other_vhosts_access.log"; \
	chown -R --no-dereference "$APACHE_RUN_USER:$APACHE_RUN_GROUP" "$APACHE_LOG_DIR"

# Apache + PHP requires preforking Apache for best results
RUN a2dismod mpm_event && a2enmod mpm_prefork

# PHP files should be handled by PHP, and should be preferred over any other file type
RUN { \
		echo '<FilesMatch \.php$>'; \
		echo '\tSetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'DirectoryIndex disabled'; \
		echo 'DirectoryIndex index.php index.html'; \
		echo; \
		echo '<Directory /var/www/>'; \
		echo '\tOptions -Indexes'; \
		echo '\tAllowOverride All'; \
		echo '</Directory>'; \
	} | tee "$APACHE_CONFDIR/conf-available/docker-php.conf" \
	&& a2enconf docker-php

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS 528995BFEDFBA7191D46839EF9BA0ADA31CBD89E 39B641343D8C104B2B146DC3F9C39DC0B9698544 F1F692238FBC1666E5A5CCD4199F9DFEF6FFBAFD

ENV PHP_VERSION 8.1.34
ENV PHP_URL="https://www.php.net/distributions/php-8.1.34.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-8.1.34.tar.xz.asc"
ENV PHP_SHA256="ffa9e0982e82eeaea848f57687b425ed173aa278fe563001310ae2638db5c251"

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends gnupg; \
	rm -rf /var/lib/apt/lists/*; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fsSL -o php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	\
	curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
	export GNUPGHOME="$(mktemp -d)"; \
	for key in $GPG_KEYS; do \
		gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key"; \
	done; \
	gpg --batch --verify php.tar.xz.asc php.tar.xz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME"; \
	\
	apt-mark auto '.*' > /dev/null; \
	apt-mark manual $savedAptMark > /dev/null; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY php-base/docker-php-source /usr/local/bin/

COPY php-base/patches /usr/src/php-patches

RUN set -eux; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		apache2-dev \
		patch \
		libargon2-dev \
		libcurl4-openssl-dev \
		libonig-dev \
		libreadline-dev \
		libsodium-dev \
		libsqlite3-dev \
		libssl-dev \
		libxml2-dev \
		zlib1g-dev \
	; \
	\
	export \
		CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
# https://github.com/php/php-src/blob/d6299206dd828382753453befd1b915491b741c6/configure.ac#L1496-L1511
		PHP_BUILD_PROVIDER='https://github.com/moodlehq/moodle-php-apache (docker-library/php + CVE-2026-109618/109619 backport)' \
		PHP_UNAME='Linux - Docker' \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
# Apply the security patches. Fail the build if any does not apply cleanly.
	for p in /usr/src/php-patches/*.patch; do \
		patch -p1 --dry-run < "$p"; \
		patch -p1 < "$p"; \
	done; \
	rm -rf /usr/src/php-patches; \
# Repack the patched tree: docker-php-ext-install re-extracts /usr/src/php.tar.xz, and the Moodle
# setup rebuilds extensions (e.g. opcache) that the patch changes. The checksum was verified above.
	tar -Jcf /usr/src/php.tar.xz --exclude=./.docker-extracted --transform "s,^\.,php-${PHP_VERSION}," -C /usr/src/php .; \
	rm -f /usr/src/php.tar.xz.asc; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	debMultiarch="$(dpkg-architecture --query DEB_BUILD_MULTIARCH)"; \
# https://bugs.php.net/bug.php?id=74125
	if [ ! -d /usr/include/curl ]; then \
		ln -sT "/usr/include/$debMultiarch/curl" /usr/local/include/curl; \
	fi; \
	test "$PHP_INI_DIR" != "${PHP_INI_DIR%/php}"; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors instead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# https://github.com/docker-library/php/issues/822
		--with-pic \
		\
# --enable-ftp is included here for compatibility with existing versions. ftp_ssl_connect() needed ftp to be compiled statically before PHP 7.0 (see https://github.com/docker-library/php/issues/236).
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		\
		--with-curl \
		--with-iconv \
		--with-openssl \
		--with-readline \
		--with-zlib \
		\
# https://github.com/bwoebi/phpdbg-docs/issues/1#issuecomment-163872806 ("phpdbg is primarily a CLI debugger, and is not suitable for debugging an fpm stack.")
		--disable-phpdbg \
		\
# in PHP 7.4+, the pecl/pear installers are officially deprecated (requiring an explicit "--with-pear")
		--with-pear \
		\
# bundled pcre does not support JIT on riscv64 until 10.41 (php 8.3+)
# https://github.com/PCRE2Project/pcre2/commits/pcre2-10.41/src/sljit/sljitNativeRISCV_64.c
# https://github.com/php/php-src/tree/php-8.3.0/ext/pcre/pcre2lib
		$(test "$gnuArch" = 'riscv64-linux-gnu' && echo '--without-pcre-jit') \
		--with-libdir="lib/$debMultiarch" \
		\
		--disable-cgi \
		\
		--with-apxs2 \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find \
		/usr/local \
		-type f \
		-perm '/0111' \
		-exec sh -euxc ' \
			strip --strip-all "$@" || : \
		' -- '{}' + \
	; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); printf "*%s\n", so }' \
		| sort -u \
		| xargs -rt dpkg-query --search \
# https://manpages.debian.org/trixie/dpkg/dpkg-query.1.en.html#S (we ignore diversions and it'll be really unusual for more than one package to provide any given .so file)
		| awk 'sub(":$", "", $1) { print $1 }' \
		| sort -u \
		| xargs -r apt-mark manual \
	; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
	\
# smoke test
	php --version

COPY php-base/docker-php-ext-* php-base/docker-php-entrypoint /usr/local/bin/

# enable OPcache by default (https://wiki.php.net/rfc/make_opcache_required)
RUN docker-php-ext-enable opcache

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

ENTRYPOINT ["docker-php-entrypoint"]
# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

COPY php-base/apache2-foreground /usr/local/bin/
WORKDIR /var/www/html

EXPOSE 80
CMD ["apache2-foreground"]

# Stage 2: Moodle specifics on top of the patched PHP.
FROM php-base

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
