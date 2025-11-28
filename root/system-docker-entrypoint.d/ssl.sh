echo
echo "#######################################"
echo "# moodle-php-apache ssl setup"
echo "#######################################"
echo "#"
echo "# Setting up Apache DocumentRoot"
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout /etc/ssl/private/ssl-cert-snakeoil.key \
  -out /etc/ssl/certs/ssl-cert-snakeoil.pem \
  -subj "/C=AU/ST=WA/L=Perth/O=Security/OU=Development/CN=example.com"

a2ensite default-ssl
a2enmod ssl

mkdir /var/www/certificates
cp /etc/ssl/certs/ssl-cert-snakeoil.pem /var/www/certificates/certificate.pem
