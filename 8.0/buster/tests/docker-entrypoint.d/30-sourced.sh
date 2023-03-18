# This file should not have a shbang! as it is expected to be sourced.
# It should not be executable either.

mkdir -p /var/www/data

(return 0 2>/dev/null) && sourced=1 || sourced=0

if [[ $sourced -eq 1 ]]; then
  echo "Sourced" >> /var/www/data/sourced.txt
fi
