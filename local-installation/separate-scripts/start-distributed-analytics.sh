#!/usr/bin/env bash

TAG=2.2.3
REGISTRY=harbor.honeur.org

read -p "Enter organization name: " ORGANIZATION
ORGANIZATION=${ORGANIZATION}

docker pull ${REGISTRY}/library/install-script:${TAG}

docker run --rm -it \
  --name feder8-installer \
  -e CURRENT_DIRECTORY=$(pwd) \
  -e IS_WINDOWS=false \
  -v /var/run/docker.sock:/var/run/docker.sock \
  ${REGISTRY}/library/install-script:${TAG} feder8 init full \
  --non_interactive --distributed_analytics --organization=${ORGANIZATION}
