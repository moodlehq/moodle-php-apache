echo
echo "#######################################"
echo "# moodle-php-apache wwwroot setup"
echo "#######################################"
echo "#"
echo "# Setting up Apache DocumentRoot"

if [ -z "$APACHE_DOCUMENT_ROOT" ]; then
    echo "# No value set for \$APACHE_DOCUMENT_ROOT. Creating default value."
    export APACHE_DOCUMENT_ROOT=/var/www/html

    if [ -d "$APACHE_DOCUMENT_ROOT/public" ]; then
        echo "# Detected /public directory."
        echo "# Using /var/www/html/public"
        export APACHE_DOCUMENT_ROOT="$APACHE_DOCUMENT_ROOT/public"
    else
        echo "# Using default Apache DocumentRoot: /var/www/html"
    fi

else
    echo "# A value was provided as an environment variable"
fi

echo "# \$APACHE_DOCUMENT_ROOT: $APACHE_DOCUMENT_ROOT"
echo "#"
echo "#######################################"
echo
