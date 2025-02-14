#!/usr/bin/env bash

TAG=2.2.0
PYTHON_VERSION=3.11
REGISTRY=harbor.honeur.org

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

THERAPEUTIC_AREA_JSON_PATH=/usr/local/lib/python3.11/site-packages/feder8-${TAG}-py${PYTHON_VERSION}.egg/cli/therapeutic_area/therapeutic-areas.json
FEDER8_LOCAL_IMAGE_JSON_PATH=/usr/local/lib/python3.11/site-packages/feder8-${TAG}-py${PYTHON_VERSION}.egg/cli/configuration/feder8-local-images.json

if [ -f "images.tar" ] && [ -f "therapeutic-areas.json" ] && [ -f "feder8-local-images.json" ]; then
  echo Loading docker images. This could take a while...
  docker load < images.tar
  docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -e IS_MAC=$IS_MAC -e DOCKER_CERT_SUPPORT=$DOCKER_CERT_SUPPORT -v ./therapeutic-areas.json:$THERAPEUTIC_AREA_JSON_PATH -v ./feder8-local-images.json:$FEDER8_LOCAL_IMAGE_JSON_PATH -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init --offline full
else
  echo Could not find 'images.tar', 'therapeutic-areas.json' and/or 'feder8-local-images.json' in the current directory. Unable to continue.
  exit 1
fi
