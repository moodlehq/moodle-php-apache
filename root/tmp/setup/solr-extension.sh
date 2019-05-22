#!/usr/bin/env bash

set -e

# Install 2.4.0 release version + macports patch. Only combination working right now.
# See #16 and #19 for more information.
hash=6e9e097c981e810d452657f23bf1945b7955f3cf
patch=https://raw.githubusercontent.com/macports/macports-ports/ed5c081eee78cbcc0f893cb845b20d9d98b3771c/php/php-solr/files/php72.patch

# Download our 'tagged' source code from git.
echo "Downloading solr extension source archive (${hash})"
curl --location \
    https://github.com/php/pecl-search_engine-solr/archive/${hash}.tar.gz \
    -o /tmp/pecl-search_engine-solr-${hash}.tar.gz

# Download patch
if [ -n $patch ]; then
    curl --location \
        $patch \
        -o /tmp/solr.patch
fi

# Extract the compressed archive.
cd /tmp
tar -xvzf pecl-search_engine-solr-${hash}.tar.gz
cd pecl-search_engine-solr-${hash}

# Apply the patch
if [ -n $patch ]; then
    patch -p0 < ../solr.patch
fi

# Compile the extension as required by a manual PECL installation.
echo "Compile solr extension"
phpize
./configure
make

# Finally, install it.
echo "Install solr extension"
make install

# Remove all the sources.
echo "Cleanup temporary folder and files"
rm /tmp/pecl-search_engine-solr-${hash} -rf
rm /tmp/pecl-search_engine-solr-${hash}.tar.gz -f
rm /tmp/solr.patch -f

# Enable it.
docker-php-ext-enable solr

# Done with this hack.
# Please, follow https://github.com/moodlehq/moodle-php-apache/issues/19.
