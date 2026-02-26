#!/usr/bin/env bash

TAG=2.3.0
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -v /var/run/docker.sock:/var/run/docker.sock -v ./info_feder8_installation:/opt/install-script/info_feder8_installation ${REGISTRY}/library/install-script:${TAG} feder8 init add-constraints-and-indexes