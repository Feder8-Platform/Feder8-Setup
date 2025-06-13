#!/usr/bin/env bash

TAG=2.2.4
REGISTRY=harbor.honeur.org

DOCKER_HOST="${DOCKER_HOST:-172.17.0.1}"

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

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -e IS_MAC=$IS_MAC -e DOCKER_CERT_SUPPORT=$DOCKER_CERT_SUPPORT -e DOCKER_HOST=$DOCKER_HOST -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init full
