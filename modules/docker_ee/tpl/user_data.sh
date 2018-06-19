#!/bin/bash

echo "Install Docker EE ..." >> /var/log/bootstrap.log 2>&1

# Follow the setup: https://docs.docker.com/install/linux/docker-ee/ubuntu/
apt-get update >> /var/log/bootstrap.log 2>&1
apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common >> /var/log/bootstrap.log 2>&1

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - >> /var/log/bootstrap.log 2>&1

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" >> /var/log/bootstrap.log 2>&1

# Get private ip
PRIVATE_IPV4=`/usr/bin/curl -s http://100.100.100.200/latest/meta-data/private-ipv4` >> /var/log/bootstrap.log 2>&1

apt-get update >> /var/log/bootstrap.log 2>&1

apt-get -y install docker-ce >> /var/log/bootstrap.log 2>&1

# Flush existing iptables
iptables -F && systemctl restart docker.service >> /var/log/bootstrap.log 2>&1

# Pull the latest version of UCP
docker image pull docker/ucp:3.0.1 >> /var/log/bootstrap.log 2>&1

# Install UCP
docker container run --rm -it --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:3.0.1 install \
  --host-address $PRIVATE_IPV4 >> /var/log/bootstrap.log 2>&1

echo "End install Docker EE ..." >> /var/log/bootstrap.log 2>&1