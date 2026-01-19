FROM debian:bullseye

# Installer paquets nécessaires
RUN apt-get update && apt-get install -y \
    mariadb-server \
    php php-fpm php-mysql \
    wget unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Créer le dossier web
RUN mkdir -p /var/www/html

# Installer WordPress
RUN wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    mv wordpress /var/www/html/wordpress && \
    rm latest.tar.gz

# Installer phpMyAdmin
RUN wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip && \
    unzip phpMyAdmin-latest-all-languages.zip && \
    mkdir -p /var/www/html/phpmyadmin && \
    mv phpMyAdmin-*/* /var/www/html/phpmyadmin/ && \
    rm phpMyAdmin-latest-all-languages.zip

# Permissions
RUN chown -R www-data:www-data /var/www/html

# Copier le script de démarrage
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
