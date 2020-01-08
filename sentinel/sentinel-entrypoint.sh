#!/bin/bash

# get container id from /proc/self/cgroup
CONTAINER_ID_LONG=`cat /proc/self/cgroup | grep 'docker' | sed 's/^.*\///' | tail -n1`

# search for the id in /etc/hosts, it uses only first 12 characters
CONTAINER_ID_SHORT=${CONTAINER_ID_LONG:0:12}
DOCKER_CONTAINER_IP_LINE=`cat /etc/hosts | grep $CONTAINER_ID_SHORT`

# get the ip address
THIS_DOCKER_CONTAINER_IP=`(echo $DOCKER_CONTAINER_IP_LINE | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')`

# set as environment variable
export DOCKER_CONTAINER_IP=$THIS_DOCKER_CONTAINER_IP

# replace placeholders in redis.conf file with environment variables

sed -i 's,{{REDIS_MASTER}},'"${REDIS_MASTER}"',g' /etc/redis/sentinel.conf
sed -i 's,{{SENTINEL_QUORUM}},'"${SENTINEL_QUORUM}"',g' /etc/redis/sentinel.conf
sed -i 's,{{SENTINEL_DOWN_AFTER}},'"${SENTINEL_DOWN_AFTER}"',g' /etc/redis/sentinel.conf
sed -i 's,{{SENTINEL_FAILOVER}},'"${SENTINEL_FAILOVER}"',g' /etc/redis/sentinel.conf

sed -i "s/\{{SENTINEL_QUORUM}}/$SENTINEL_QUORUM/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_DOWN_AFTER/$SENTINEL_DOWN_AFTER/g" /etc/redis/sentinel.conf
sed -i "s/\$SENTINEL_FAILOVER/$SENTINEL_FAILOVER/g" /etc/redis/sentinel.conf

sed -i 's,{{SENTINEL_CONTAINER_IP}},'"${DOCKER_CONTAINER_IP}"',g' /etc/redis/sentinel.conf

exec docker-entrypoint.sh redis-server /etc/redis/sentinel.conf --sentinel --protected-mode no
