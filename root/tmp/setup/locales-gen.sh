#!/usr/bin/env bash

set -e

echo "Installing apt dependencies"

# Packages for installing locales.
RUNTIME_LOCALES="locales locales-all"

apt-get update
apt-get install -y --no-install-recommends apt-transport-https \
    $RUNTIME_LOCALES

# Keep our image size down..
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
