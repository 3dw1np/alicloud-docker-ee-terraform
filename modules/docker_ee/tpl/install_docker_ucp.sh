#!/bin/bash

echo "Install Docker UCP ..." >> /var/log/bootstrap.log 2>&1

EIPV4=`/usr/bin/curl -s http://100.100.100.200/latest/meta-data/eipv4` >> /var/log/bootstrap.log 2>&1
PRIVATE_IPV4=`/usr/bin/curl -s http://100.100.100.200/latest/meta-data/private-ipv4` >> /var/log/bootstrap.log 2>&1

# Pull the latest version of UCP
docker image pull docker/ucp:3.0.2 >> /var/log/bootstrap.log 2>&1

# Install UCP
docker container run --rm --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:3.0.2 install \
  --host-address $PRIVATE_IPV4 \
  --san $EIPV4 \
  --admin-username admin \
  --admin-password admindocker >> /var/log/bootstrap.log 2>&1

echo "End install Docker UCP ..." >> /var/log/bootstrap.log 2>&1