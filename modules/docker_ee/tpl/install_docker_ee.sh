#!/bin/bash

echo "Install Docker EE ..." >> /var/log/bootstrap.log 2>&1

DOCKER_EE_URL="${DOCKER_EE_URL}"

# Follow the setup: https://docs.docker.com/install/linux/docker-ee/ubuntu/
apt-get update >> /var/log/bootstrap.log 2>&1
apt-get -y install \
  apt-transport-https \
  ca-certificates \
  curl \
  software-properties-common >> /var/log/bootstrap.log 2>&1

curl -fsSL "$DOCKER_EE_URL/ubuntu/gpg" | apt-key add - >> /var/log/bootstrap.log 2>&1

add-apt-repository \
  "deb [arch=amd64] $DOCKER_EE_URL/ubuntu \
  $(lsb_release -cs) \
  stable-17.06" >> /var/log/bootstrap.log 2>&1


apt-get update >> /var/log/bootstrap.log 2>&1
apt-get -y install docker-ee >> /var/log/bootstrap.log 2>&1

echo "End install Docker EE ..." >> /var/log/bootstrap.log 2>&1