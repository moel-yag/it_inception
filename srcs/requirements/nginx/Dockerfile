# Base image : penultimate stable version  
FROM debian:bookworm

# insatll nginx and ssl certificate && remove all other trash to make container light
RUN apt update && apt install -y \
    nginx \
    openssl \
    && rm  -rf /var/lib/apt/lists/*

# create a folder for ssl certificate
RUN mkdir -p /etc/nginx/ssl

# copy the nginx configuration into container or override the default config
COPY ./conf/nginx.conf /etc/nginx/conf.d/default.conf

# copy the script to container 
COPY ./tools/setup.sh /usr/local/bin/setup.sh

# give permission to execute the script inside container
RUN chmod +x /usr/local/bin/setup.sh

# assign an https port
EXPOSE 443

# run the script to install dependency inside the container
ENTRYPOINT ["/usr/local/bin/setup.sh"]
