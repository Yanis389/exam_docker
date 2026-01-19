#!/bin/bash

mysqld_safe &
sleep 5

mysql -u root << EOF
CREATE DATABASE IF NOT EXISTS yanis;
CREATE USER IF NOT EXISTS 'yanis'@'localhost' IDENTIFIED BY 'yanis';
GRANT ALL PRIVILEGES ON wordpress.* TO 'yanis'@'localhost';
FLUSH PRIVILEGES;
EOF

if [ ! -f /var/www/html/wordpress/wp-config.php ]; then
    cp /var/www/html/wordpress/wp-config-sample.php /var/www/html/wordpress/wp-config.php
    sed -i "s/database_name_here/yanis/" /var/www/html/wordpress/wp-config.php
    sed -i "s/username_here/yanis/" /var/www/html/wordpress/wp-config.php
    sed -i "s/password_here/yanis/" /var/www/html/wordpress/wp-config.php
fi

tail -f /dev/null
