#!/usr/bin/env bash

TAG=2.3.4
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/info_feder8_installation:/opt/install-script/info_feder8_installation ${REGISTRY}/library/install-script:${TAG} feder8 init full --non_interactive --zepellin
