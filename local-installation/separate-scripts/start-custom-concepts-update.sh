#!/usr/bin/env bash

TAG=2.3.0
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock -v ./info_feder8_installation:/usr/local/lib/python3.11/site-packages/feder8-${TAG}-py3.11.egg/cli/info_feder8_installation ${REGISTRY}/library/install-script:${TAG} feder8 init update-custom-concepts
