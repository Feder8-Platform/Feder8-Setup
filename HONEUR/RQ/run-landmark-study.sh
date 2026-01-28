#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_36
IMAGE=landmark-study
VERSION=V13
TAG=$VERSION

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull Docker image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name landmark-study \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=9d91de06-c135-4eaf-b0ec-ae3ab3dc6c74 \
-v "$PWD/results":/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

