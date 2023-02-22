FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends redis-server && apt-get clean && find /var/lib/apt/lists -type f -delete -print && rm -rf /var/lib/redis
COPY files/redis.conf /etc/redis.conf
COPY files/start* /usr/bin/
RUN chmod +x /usr/bin/start-*
CMD ["/usr/bin/start-redis"]
