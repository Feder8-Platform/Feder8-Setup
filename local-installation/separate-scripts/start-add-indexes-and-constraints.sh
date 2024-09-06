#!/usr/bin/env bash

TAG=2.1.3
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init add-constraints-and-indexes
#docker run --rm -it --name feder8-installer -v /var/run/docker.sock:/var/run/docker.sock -v ./feder8-local-images.json:/opt/install-script/feder8-local-images.json feder8/install-script:testing feder8 init add-constraints-and-indexes
#docker run --rm -it --name feder8-installer -v /var/run/docker.sock:/var/run/docker.sock -v ./feder8-local-images.json:/opt/install-script/feder8-local-images.json ${REGISTRY}/library/install-script:${TAG} feder8 init add-constraints-and-indexes