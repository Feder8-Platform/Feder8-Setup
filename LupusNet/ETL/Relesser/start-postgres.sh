#!/usr/bin/env bash

TAG=2.0.22
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}

curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Relesser/feder8-local-images-override.json --output feder8-local-images-override.json
docker run --rm -it --name feder8-installer -v ${PWD}/feder8-local-images-override.json:/opt/install-script/cli/configuration/feder8-local-images.json -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init postgres -ta lupus --expose-database-on-host false
