#!/usr/bin/env bash

set -e

echo "Installing Moodle Python mlbackend"

apt-get update
apt-get install -y --no-install-recommends python2.7 python-pip python2.7-dev
pip -V
pip install "tensorflow>=1.0.0,<1.1"
pip install moodlemlbackend

# Keep our image size down.
rm -rf ~/.cache/pip
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
