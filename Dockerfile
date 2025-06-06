FROM php:8.2-apache

# Instalar dependências
RUN apt-get update && apt-get install -y \
    libzip-dev \
    zip \
    unzip \
    git \
    curl \
    libonig-dev \
    libpng-dev \
    libxml2-dev \
    libsqlite3-dev \
    sqlite3 \
    libcurl4-openssl-dev \
    libssl-dev \
    supervisor

# Instalar extensões PHP
RUN docker-php-ext-install pdo_mysql pdo_sqlite zip

# Ativar mod_rewrite do Apache
RUN a2enmod rewrite

# Ajustar o root do Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copiar arquivos da aplicação
COPY . /var/www/html

WORKDIR /var/www/html

# Instalar o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar dependências PHP/Laravel
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Criar banco SQLite e permissões
RUN mkdir -p database && \
    touch database/database.sqlite && \
    chown -R www-data:www-data database storage bootstrap/cache

# Configurar Supervisor para queue:work e reverb:start
COPY ./docker/supervisord.conf /etc/supervisord.conf

# Comando padrão
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
