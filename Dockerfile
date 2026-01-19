FROM debian:bullseye

# Installer paquets nécessaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    php php-fpm php-mysql \
    wget unzip ca-certificates \
    nginx openssl \
    && rm -rf /var/lib/apt/lists/*

# Créer le dossier web
RUN mkdir -p /var/www/html

# Télécharger WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress /var/www/html/wordpress && \
    rm latest.tar.gz

# Télécharger phpMyAdmin
RUN wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip && \
    unzip phpMyAdmin-latest-all-languages.zip && \
    mkdir -p /var/www/html/phpmyadmin && \
    mv phpMyAdmin-*/* /var/www/html/phpmyadmin/ && \
    rm phpMyAdmin-latest-all-languages.zip

# Permissions pour Nginx et PHP
RUN chown -R www-data:www-data /var/www/html && \
    find /var/www/html -type d -exec chmod 755 {} \; && \
    find /var/www/html -type f -exec chmod 644 {} \; && \
    chmod 775 /var/www/html/wordpress/wp-content/uploads || true && \
    chmod 775 /var/www/html/phpmyadmin/tmp || true

# Copier start.sh et configuration Nginx
COPY start.sh /start.sh
COPY nginx.conf /etc/nginx/sites-available/default
RUN chmod +x /start.sh

CMD ["/start.sh"]
