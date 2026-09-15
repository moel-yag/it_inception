#!/bin/bash

if [ ! -f /etc/nginx/ssl/inception.crt ]; then
  echo "Nginx: Setting up SSL certificate ..."

  # req -x509 : Tells OpenSSL we want to generate a standard X.509 certificate.
  # -nodes : It means "don't encrypt the private key with a password
  # -out -keyout : Defines where to save the public certificate (.crt) and the private key (.key).
  openssl req -x509 -days 365 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=MA/ST=fez/L=Bengruire/O=1337/OU=Student/CN=$DOMAIN_NAME"

  echo "Nginx: SSL certificate generated!"
else
  echo "Nginx: SSL certificate already exists."
fi

# Start Nginx in the foreground
echo "Nginx: Starting web server..."
exec nginx -g "daemon off;"
