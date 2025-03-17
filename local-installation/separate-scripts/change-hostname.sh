#!/usr/bin/env bash

REGISTRY=harbor.honeur.org
REPOSITORY=library
IMAGE=install-script
TAG=2.2.1

if systemctl show --property ActiveState docker &> /dev/null; then
    DOCKER_CERT_SUPPORT=true
else
    DOCKER_CERT_SUPPORT=false
fi

if [[ $OSTYPE == 'darwin'* ]]; then
  IS_MAC=true
else
  IS_MAC=false
fi

docker pull ${REGISTRY}/${REPOSITORY}/${IMAGE}:${TAG}

docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=${PWD} -e IS_WINDOWS=false -e IS_MAC=$IS_MAC -e DOCKER_CERT_SUPPORT=$DOCKER_CERT_SUPPORT -e ENVIRONMENT=PRD -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/${REPOSITORY}/${IMAGE}:${TAG} feder8 init change-hostname
