# FROM php:7.4-apache

# RUN apt update && apt upgrade -y
# RUN apt install -y \
#   default-mysql-client \
#   zlib1g-dev \
#   libpng-dev \
#   libjpeg-dev \
#   libfreetype-dev
# RUN docker-php-ext-install mysqli && \
#   docker-php-ext-enable mysqli && \
#   docker-php-ext-configure gd --with-freetype --with-jpeg && \
#   docker-php-ext-install gd
# RUN apt clean

# # Create the required directories
# RUN mkdir -p /var/testlink/logs /var/testlink/upload_area
# RUN chmod -R 777 /var/testlink/logs /var/testlink/upload_area

# RUN mkdir -p /var/www/testlink

# WORKDIR /var/www/testlink

# COPY . .
# COPY ./docker/php.ini-production /usr/local/etc/php/conf.d/php.ini

# RUN  chown -R www-data:www-data /var/www/testlink
# RUN rm -rf docker
# ENV APACHE_DOCUMENT_ROOT /var/www/testlink
# RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
# RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# USER www-data

# EXPOSE 80
# CMD ["apache2ctl", "-D", "FOREGROUND"]


FROM php:7.4-apache

# Update and upgrade the system
RUN apt update && apt upgrade -y

# Install dependencies
RUN apt install -y \
  default-mysql-client \
  zlib1g-dev \
  libpng-dev \
  libjpeg-dev \
  libfreetype-dev \
  gnupg2 \
  curl \
  unixodbc-dev \
  apt-transport-https

# Configure MySQL extensions
RUN docker-php-ext-install mysqli && \
  docker-php-ext-enable mysqli && \
  docker-php-ext-configure gd --with-freetype --with-jpeg && \
  docker-php-ext-install gd

# Add Microsoft repository for MSSQL
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update

# Install MSSQL drivers and tools
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 mssql-tools && \
    pecl install pdo_sqlsrv sqlsrv && \
    docker-php-ext-enable pdo_sqlsrv sqlsrv

# Clean up
RUN apt clean

# Create required directories
RUN mkdir -p /var/testlink/logs /var/testlink/upload_area
RUN chmod -R 777 /var/testlink/logs /var/testlink/upload_area
RUN mkdir -p /var/www/testlink

# Set working directory
WORKDIR /var/www/testlink

# Copy application files
COPY . .
COPY ./docker/php.ini-production /usr/local/etc/php/conf.d/php.ini

# Set permissions for the application
RUN chown -R www-data:www-data /var/www/testlink
RUN rm -rf docker

# Configure Apache DocumentRoot
ENV APACHE_DOCUMENT_ROOT /var/www/testlink
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Switch to non-root user
USER www-data

# Expose port
EXPOSE 80

# Start Apache in the foreground
CMD ["apache2ctl", "-D", "FOREGROUND"]

