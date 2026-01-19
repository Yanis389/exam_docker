FROM debian:bullseye

ENV DEBIAN_FRONTEND=noninteractive

# Installation des services
RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    mariadb-server mariadb-client \
    php7.4-fpm php7.4-mysql php7.4-mbstring php7.4-zip php7.4-gd php7.4-curl php7.4-xml \
    wget unzip ca-certificates curl dos2unix \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /etc/init.d/mariadb /etc/init.d/mysql

# Création des dossiers web
RUN mkdir -p \
    /var/www/html \
    /var/www/html/wordpress \
    /var/www/html/phpmyadmin \
    /var/www/html/files

# Installation WordPress
RUN wget -q https://wordpress.org/latest.tar.gz \
    && tar -xzf latest.tar.gz \
    && mv wordpress/* /var/www/html/wordpress/ \
    && rm -rf wordpress latest.tar.gz

# Installation phpMyAdmin
RUN wget -q https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.zip \
    && unzip -q phpMyAdmin-latest-all-languages.zip \
    && cp -r phpMyAdmin-*/* /var/www/html/phpmyadmin/ \
    && rm -rf phpMyAdmin-* phpMyAdmin-latest-all-languages.zip

# Permissions
RUN chown -R www-data:www-data /var/www/html

# Copier nginx.conf et script
COPY nginx.conf /etc/nginx/sites-available/default
COPY start.sh /start.sh
RUN dos2unix /start.sh && chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
