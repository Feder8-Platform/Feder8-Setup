#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_36
IMAGE=landmark-study
VERSION=V12
TAG=$VERSION

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull Docker image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name landmark-study \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=21561f9f-6ef6-469b-8c4d-32444303a51e \
-v "$PWD/results":/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

