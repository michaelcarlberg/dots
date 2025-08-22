#!/bin/bash

mkdir -p /tmp/Zoneminder/data

docker run -d \
  --name=zoneminder \
  --net=bridge \
  --privileged=false \
  --shm-size=8G \
  -p 8443:443/tcp \
  -p 9000:9000/tcp \
  -p 8080:80/tcp \
  -e TZ=America/New_York \
  -e PUID=99 \
  -e PGID=100 \
  -e MULTI_PORT_START=0 \
  -e MULTI_PORT_END=0 \
  -e NO_START_ZM=1 \
  -v /tmp/Zoneminder:/config:rw \
  -v /tmp/Zoneminder/data:/var/cache/zoneminder:rw \
  dlandon/zoneminder.machine.learning

if ! read -t 300 -r < <(docker logs -f zoneminder 2>&1 | grep --line-buffered 'MySql and Zoneminder not started.'); then
  exit 1
fi

docker exec zoneminder bash -c 'service mysqld start'
docker exec zoneminder bash -c 'service zoneminder start'
docker exec zoneminder bash -c 'service zoneminder status'
