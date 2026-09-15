# Base Image: Penultimate stable version of Debian
FROM debian:bookworm

# Update and install required packages in a single layer to save space
RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    mariadb-client \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download WP-CLI and make it globally accessible
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create the PID directory required by PHP-FPM and the web root directory
RUN mkdir -p /run/php /var/www/html/wordpress

# Set the correct ownership for the web directory so PHP can write to it
RUN chown -R www-data:www-data /var/www/html/wordpress

# Copy our custom configurations into the container
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh

# Make sure the entrypoint script is executable
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set the working directory
WORKDIR /var/www/html/wordpress

# Document the port the container will listen on
EXPOSE 9000

# Define the entrypoint script that will run when the container starts
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
