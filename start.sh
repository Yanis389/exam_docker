#!/bin/sh
set -e

# Variables d'environnement
: "${AUTOINDEX:=off}"
: "${DB_NAME:=yanis}"
: "${DB_USER:=yanis}"
: "${DB_PASS:=yanis}"
: "${DB_ROOT_PASS:=rootpass}"

# Autoindex Nginx
if [ "$AUTOINDEX" = "on" ]; then
  sed -i 's/__AUTOINDEX__/on/g' /etc/nginx/sites-available/default
else
  sed -i 's/__AUTOINDEX__/off/g' /etc/nginx/sites-available/default
fi

# Dossier runtime MySQL
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Lancer MariaDB
mysqld_safe --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &

# Attendre que MariaDB démarre
MYSQL_CLI="mysql --protocol=socket --socket=/var/run/mysqld/mysqld.sock"
i=0
while [ "$i" -lt 30 ]; do
  if $MYSQL_CLI -e "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  i=$((i + 1))
  sleep 1
done

# Créer DB et utilisateur
$MYSQL_CLI <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
SQL

# Landing page
cat > /var/www/html/index.php <<'PHP'
<?php
echo "<h1>Server OK</h1>";
echo "<ul>";
echo "<li><a href='/wordpress/'>WordPress</a></li>";
echo "<li><a href='/phpmyadmin/'>phpMyAdmin</a></li>";
echo "<li><a href='/files/'>Autoindex folder</a></li>";
echo "</ul>";
PHP
chown www-data:www-data /var/www/html/index.php

# Lancer PHP-FPM et Nginx
service php7.4-fpm start
nginx -g "daemon off;"
