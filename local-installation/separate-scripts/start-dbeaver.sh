#!/usr/bin/env bash

TAG=2.3.1
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} -v $(pwd)/info_feder8_installation:/opt/install-script/info_feder8_installation feder8 init full --non_interactive --dbeaver
