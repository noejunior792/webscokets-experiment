FROM php:8.2-apache

# Instalar dependências do sistema
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
    supervisor \
    gnupg \
    ca-certificates

# Instalar extensões PHP
RUN docker-php-ext-install pdo_mysql pdo_sqlite zip

# Ativar mod_rewrite do Apache
RUN a2enmod rewrite

# Ajustar o document root
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Copiar código
COPY . /var/www/html

WORKDIR /var/www/html

# Instalar Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instalar dependências PHP
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Instalar Node.js e npm (Node 22.x, compatível com Laravel Mix/Vite)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs

# Instalar dependências JS e buildar frontend
RUN npm install && npm run build

# Criar e configurar SQLite + permissões
RUN mkdir -p database && \
    touch database/database.sqlite && \
    chown -R www-data:www-data database storage bootstrap/cache

# Copiar configuração do Supervisor
COPY ./docker/supervisord.conf /etc/supervisord.conf

# Comando padrão
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
