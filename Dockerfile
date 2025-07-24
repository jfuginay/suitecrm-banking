# Multi-service Dockerfile for SuiteCRM Banking Demo
FROM php:7.4-apache AS suitecrm

# Install dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    libicu-dev \
    libxml2-dev \
    libldap2-dev \
    libgmp-dev \
    libkrb5-dev \
    libc-client-dev \
    gnucobol \
    mariadb-client \
    curl \
    git \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        mysqli \
        pdo_mysql \
        zip \
        intl \
        soap \
        bcmath \
        gmp \
        opcache

# Enable Apache modules
RUN a2enmod rewrite headers expires

# Copy SuiteCRM files
COPY --from=builder /app/SuiteCRM /var/www/html/
COPY --from=builder /app/custom /var/www/html/custom/
COPY --from=builder /app/modules /var/www/html/modules/

# Set permissions
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 775 /var/www/html/cache \
    && chmod -R 775 /var/www/html/custom \
    && chmod -R 775 /var/www/html/modules \
    && chmod -R 775 /var/www/html/upload

# Copy demo configuration
COPY demo-config.php /var/www/html/config_override.php

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s \
    CMD curl -f http://localhost/ || exit 1

EXPOSE 80

# COBOL API Service
FROM node:16-alpine AS cobol-api

# Install GnuCOBOL
RUN apk add --no-cache gnucobol gnucobol-dev build-base

WORKDIR /app

# Copy COBOL services
COPY cobol-services/package*.json ./
RUN npm ci --only=production

COPY cobol-services/ ./

# Compile COBOL programs
RUN chmod +x compile-cobol.sh && ./compile-cobol.sh

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD curl -f http://localhost:3000/health || exit 1

EXPOSE 3000

CMD ["npm", "start"]