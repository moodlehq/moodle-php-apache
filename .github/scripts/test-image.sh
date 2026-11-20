#!/usr/bin/env bash
set -euo pipefail

context=$(cd "$1" && pwd -P)
image=$2
prefix="moodle-php-apache-test-${GITHUB_RUN_ID:-local}-$$"
containers=()

cleanup() {
    status=$?
    trap - EXIT
    for container in "${containers[@]}"; do
        if (( status != 0 )); then
            docker logs "$container" || true
        fi
        docker rm -f "$container" >/dev/null || true
    done
    exit "$status"
}
trap cleanup EXIT

start_container() {
    name="$prefix-${#containers[@]}"
    docker run --name "$name" -d -p 127.0.0.1::80 "$@" "$image" >/dev/null
    containers+=("$name")
}

check_http() {
    local port
    port=$(docker port "$1" 80/tcp)
    curl --fail --silent --show-error --retry 10 --retry-connrefused --retry-delay 1 \
        --max-time 2 "http://${port}/$2"
}

fixtures="$context/tests/fixtures"
if [[ -d "$fixtures/entrypoint" ]]; then
    fixtures="$fixtures/entrypoint"
fi

start_container \
    -v "$fixtures:/var/www/html" \
    -v "$context/tests/docker-entrypoint.d:/docker-entrypoint.d" \
    -e PHP_INI-memory_limit=256M \
    -e PHP_INI-apc.enabled=0 \
    -e PHP_INI-apc.enable_cli=0 \
    -e PHP_INI-pcov.enabled=1 \
    -e PHP_INI-upload_max_filesize=20M \
    -e PHP_EXTENSION_xhprof=1
docker exec "$name" php /var/www/html/test.php
docker exec "$name" php /var/www/html/check-ini.php
docker exec "$name" php /var/www/html/check-entrypoint-scripts.php
if [[ -f "$fixtures/check-php-patches.php" ]]; then
    docker exec "$name" php /var/www/html/check-php-patches.php
fi
check_http "$name" test.php
check_http "$name" check-ini.php

documentroot="$context/tests/fixtures/documentroot"
if [[ -d "$documentroot" ]]; then
    start_container -v "$documentroot:/var/www/html"
    check_http "$name" test.php
    start_container -v "$documentroot/public:/var/www/html"
    check_http "$name" test.php
    start_container -v "$documentroot:/srv/moodle" -e APACHE_DOCUMENT_ROOT=/srv/moodle
    check_http "$name" notpublic.php
    start_container -v "$documentroot/public:/srv/moodle" -e APACHE_DOCUMENT_ROOT=/srv/moodle
    check_http "$name" test.php
fi
