FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server && apt-get clean && find /var/lib/apt/lists -type f -delete -print && rm -rf /var/lib/mysql
COPY files/99-custom.cnf /etc/mysql/mariadb.conf.d/
COPY files/start-* /usr/sbin/
RUN chmod +x /usr/sbin/*
CMD ["/usr/sbin/start-mariadb"]
