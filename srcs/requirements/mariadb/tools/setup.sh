#!/bin/bash

SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# 1. Check if the physical database folder exists
if [ ! -d "/var/lib/mysql/$SQL_DATABASE" ]; then
    echo "Database not found. Initializing..."

    # Start MariaDB in the background temporary (& run in the background)
    mysqld_safe &

    # Wait a few seconds for the background process to fully boot
    sleep 5

    # Run the setup commands (no password needed because root has no password yet!)
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "FLUSH PRIVILEGES;"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    # Gracefully shut down the background process using the NEW root password
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

    echo "Database initialization complete."
else
    echo "Database already exists. Skipping initialization."
fi

# 2. Hand over PID 1 to MariaDB in the foreground
echo "Starting MariaDB database server..."
exec mysqld_safe
