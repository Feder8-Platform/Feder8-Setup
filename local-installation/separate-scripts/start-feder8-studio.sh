#!/usr/bin/env bash

TAG=2.2.4
REGISTRY=harbor.honeur.org

if systemctl show --property ActiveState docker &> /dev/null; then
    DOCKER_CERT_SUPPORT=true
else
    DOCKER_CERT_SUPPORT=false
fi

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -e DOCKER_CERT_SUPPORT=$DOCKER_CERT_SUPPORT -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init full --non_interactive --feder8_studio
