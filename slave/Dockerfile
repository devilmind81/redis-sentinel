FROM redis:5

COPY ./redis.conf /etc/redis/redis.conf
RUN chown redis:redis /etc/redis/redis.conf

COPY ./redis-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/redis-entrypoint.sh

EXPOSE 6379

ENTRYPOINT ["redis-entrypoint.sh"]