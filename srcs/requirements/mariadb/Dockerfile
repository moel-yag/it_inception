FROM debian:bookworm

RUN apt update && apt install -y \
    mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY ./conf/server.cnf /etc/mysql/mariadb.conf.d/server.cnf

COPY ./tools/setup.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/setup.sh"]
