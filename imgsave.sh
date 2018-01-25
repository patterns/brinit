#!/usr/bin/env bash
set -e

if [ "$EUID" -ne 0 ]; then
    echo "This script uses functionality which requires root privileges"
    exit 1
fi

acbuild --debug begin

# In the event of the script exiting, end the build
trap "{ export EXT=$?; acbuild --debug end && exit $EXT; }" EXIT

# base image on Bitnami Mini Debian
acbuild --debug dep add quay.io/bitnami/minideb

# Install Wordpress dependencies
acbuild --debug run -- apt update
acbuild --debug run -- install_packages php php-fpm php-cli php-curl php-imap php-mbstring \
                                        php-memcached php-mysql php-mcrypt php-gd php-xml \
                                        php-zip \
                                        git curl nginx ca-certificates composer unzip \
                                        libnuma-dev php-intl php-pear php-imagick \
                                        php-pspell php-recode php-tidy \
                                        php-xmlrpc mysql-client    #####postfix python-pip supervisor php-sqlite3

# Install WP-CLI
acbuild --debug run -- curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
acbuild --debug run -- /bin/sh -c "chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp"


acbuild --debug copy php-fpm.conf /etc/php/7.0/fpm/php-fpm.conf
acbuild --debug copy nginx-default /etc/nginx/sites-available/default
#acbuild --debug run -- /bin/sh -c "echo 'daemon off;' >> /etc/nginx/nginx.conf"
#acbuild --debug copy supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Choose the user to run-as inside the container
acbuild --debug run -- adduser --system --home /home/gopher --shell /bin/sh --group --disabled-password gopher
acbuild --debug run -- usermod -a -G www-data gopher
acbuild --debug set-user gopher

# Suppress Sendmail (called by 'wp core install')
####acbuild --debug run -- update-rc.d postfix disable

# Add a port for http traffic on port 80
acbuild --debug port add http tcp 80

# Make the container's entrypoint the shell for now
#acbuild --debug set-exec -- /usr/bin/supervisord
#acbuild --debug set-exec -- /usr/sbin/nginx -g 'master_process off;'
acbuild --debug set-exec -- /bin/sh

# Add a mount point for www root
acbuild --debug run -- chmod 777 /var/www/html
acbuild --debug run -- chown -R www-data:www-data /var/www/html
acbuild --debug mount add html /var/www/html

# Write the result
acbuild --debug set-name patterns/brinit
acbuild --debug label add version 0.0.1
acbuild --debug annotation add authors "杜興怡"
acbuild --debug write --overwrite brinit-0.0.1-linux-amd64.aci
