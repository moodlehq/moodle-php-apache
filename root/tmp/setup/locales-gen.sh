#!/usr/bin/env bash

set -e

echo "Installing apt dependencies"

# Packages for installing locales.
RUNTIME_LOCALES="locales"

apt-get update
apt-get install -y --no-install-recommends apt-transport-https \
    $RUNTIME_LOCALES

echo "Installing UTF-8 locales"

# Generate the locales configuration for all possible UTF-8 locales.
grep UTF-8 /usr/share/i18n/SUPPORTED > /etc/locale.gen
locale-gen

# Keep our image size down..
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
