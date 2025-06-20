#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_36
IMAGE=landmark-study
VERSION=V9
TAG=$VERSION

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull Docker image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name landmark-study \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=c10fcc29-ad17-42ec-893d-35638ae4b989 \
-v "$PWD/results":/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

