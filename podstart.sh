#!/bin/sh

# todo: utilize separate nginx/PHP-fpm container

WWWROOT=$HOME/pub
ACIIMG=$HOME/images/brinit-0.0.1-linux-amd64.aci 

sudo rkt --insecure-options=image \
         --volume html,kind=host,source=$WWWROOT,readOnly=false \
         --set-env=MYSQL_ROOT_PASSWORD=wordpress \
         --set-env=WORDPRESS_DB_HOST=127.0.0.1 \
         --set-env=WORDPRESS_DB_PASSWORD=wordpress \
         --net=host --dns=8.8.8.8 --dns=8.8.4.4 \
         run docker://mariadb  \
         $ACIIMG


#         --port=http:8080 \

# /////
# //after attaching to the pod's app for compbr, call create-project to init bedrock
# //cd /var/www/html && su -s /bin/sh -c "composer create-project roots/bedrock ." gopher
# //vi /var/www/html/.env    #with https://roots.io/salts.html
# //su -s /bin/sh -c "wp db create" gopher
# //su -s /bin/sh -c "wp core install --url=http://example.dev --admin_user=admin --admin_password=test --admin_email=test@example.dev --title=Example" gopher
# ///usr/sbin/nginx -g "master_process off"
# Install VersionPress
# curl -L -O https://github.com/versionpress/versionpress/releases/download/4.0-beta/versionpress-4.0-beta.zip
# unzip versionpress-4.0-beta.zip -d /var/www/html/web/wp-content/plugins


