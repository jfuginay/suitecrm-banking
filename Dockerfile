# Simplest possible Dockerfile for Railway
FROM php:7.4-apache

# Install minimal dependencies
RUN docker-php-ext-install mysqli

# Create a simple index page
RUN echo '<?php \
echo "<h1>SuiteCRM Banking Edition</h1>"; \
echo "<p>Demo deployment successful!</p>"; \
echo "<p>Full CRM installation coming soon.</p>"; \
?>' > /var/www/html/index.php

# Remove default index.html
RUN rm -f /var/www/html/index.html

# Configure Apache to use PORT env variable
RUN sed -i 's/80/${PORT}/g' /etc/apache2/sites-available/000-default.conf \
    && sed -i 's/80/${PORT}/g' /etc/apache2/ports.conf

EXPOSE ${PORT}

# Start Apache
CMD ["bash", "-c", "sed -i \"s/80/${PORT}/g\" /etc/apache2/sites-available/000-default.conf && sed -i \"s/80/${PORT}/g\" /etc/apache2/ports.conf && apache2-foreground"]