#!/usr/bin/env bash
set -euo pipefail

is_newer() {
    local old=$1 new=$2 i
    local -a old_parts new_parts
    IFS=. read -r -a old_parts <<< "$old"
    IFS=. read -r -a new_parts <<< "$new"
    for ((i = 0; i < ${#old_parts[@]} || i < ${#new_parts[@]}; i++)); do
        local old_part=${old_parts[i]:-0} new_part=${new_parts[i]:-0}
        if (( 10#$new_part > 10#$old_part )); then return 0; fi
        if (( 10#$new_part < 10#$old_part )); then return 1; fi
    done
    return 1
}

matrix=$(bash .github/scripts/build-matrix.sh)
latest_timezone=$(curl -fsSL --retry 3 https://pecl.php.net/rest/r/timezonedb/stable.txt)
if [[ ! "$latest_timezone" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
    echo "Invalid latest timezonedb version: $latest_timezone" >&2
    exit 1
fi
rebuild=()

while IFS= read -r version; do
    image="moodlehq/moodle-php-apache:$version"
    status=$(curl -sS --retry 3 -o /dev/null -w '%{http_code}' \
        "https://hub.docker.com/v2/repositories/moodlehq/moodle-php-apache/tags/$version")
    case "$status" in
        200) ;;
        404)
            echo "$version: image does not exist; scheduling its first build" >&2
            rebuild+=("$version")
            continue
            ;;
        *)
            echo "Could not check $image on Docker Hub (HTTP $status)" >&2
            exit 1
            ;;
    esac
    current=$(docker run --rm "$image" php -r 'echo PHP_VERSION, " ", timezone_version_get(), "\n";' | tail -n 1)
    read -r php_version timezone_version <<< "$current"
    if [[ ! "$timezone_version" =~ ^[0-9]+(\.[0-9]+)+$ ]]; then
        echo "Invalid timezone version in $image: $timezone_version" >&2
        exit 1
    fi

    needs_rebuild=false
    if is_newer "$timezone_version" "$latest_timezone"; then
        needs_rebuild=true
    fi

    if [[ "$php_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        php_series=${php_version%.*}
        latest_php=$(curl -fsSL --retry 3 "https://www.php.net/releases/?json&version=$php_series" |
            jq -er '.version | select(test("^[0-9]+\\.[0-9]+\\.[0-9]+$"))')
        if is_newer "$php_version" "$latest_php"; then
            needs_rebuild=true
        fi
    elif [[ "$php_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+[-a-zA-Z0-9.]+$ ]]; then
        echo "$version: PHP $php_version is not a stable version; skipping PHP comparison" >&2
    else
        echo "Invalid PHP version in $image: $php_version" >&2
        exit 1
    fi

    echo "$version: PHP $php_version, timezonedb $timezone_version, rebuild $needs_rebuild" >&2
    if [[ "$needs_rebuild" == true ]]; then
        rebuild+=("$version")
    fi
done < <(jq -r '.[].id' <<< "$matrix")

if ((${#rebuild[@]} > 0)); then
    (IFS=,; echo "${rebuild[*]}")
fi
