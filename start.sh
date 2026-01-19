#!/bin/bash

mysqld_safe &
sleep 5

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS yanis;
CREATE USER IF NOT EXISTS 'yanis'@'localhost' IDENTIFIED BY 'yanis';
GRANT ALL PRIVILEGES ON yanis.* TO 'yanis'@'localhost';
FLUSH PRIVILEGES;
EOF

if [ ! -f /var/www/html/wordpress/wp-config.php ]; then
    cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
    sed -i "s/database_name_here/yanis/" /var/www/html/wordpress/wp-config.php
    sed -i "s/username_here/yanis/" /var/www/html/wordpress/wp-config.php
    sed -i "s/password_here/yanis/" /var/www/html/wordpress/wp-config.php
fi

chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

mkdir -p /var/www/html/wordpress/wp-content/uploads
mkdir -p /var/www/html/phpmyadmin/tmp
chmod 775 /var/www/html/wordpress/wp-content/uploads
chmod 775 /var/www/html/phpmyadmin/tmp

mkdir -p /run/php
chown www-data:www-data /run/php

export PATH=$PATH:/usr/sbin

php-fpm7.4 -F &
nginx -g 'daemon off;'
