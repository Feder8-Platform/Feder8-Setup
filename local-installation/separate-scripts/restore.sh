#!/usr/bin/env bash

TAG=2.3.1
REGISTRY=harbor.honeur.org
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock -v ./info_feder8_installation:/opt/install-script/info_feder8_installation ${REGISTRY}/library/install-script:${TAG} feder8 init restore
