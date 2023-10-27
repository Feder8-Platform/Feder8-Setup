#!/usr/bin/env bash

TAG=2.0.27
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e FEDER8_IPV4_ONLY=true -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init nginx -ta phederation
