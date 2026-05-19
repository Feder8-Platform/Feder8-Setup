#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq3-feasibility
TAG=1.0.3

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name lupusnet-rq3 \
--memory-swap -1 \
--env THERAPEUTIC_AREA=lupus \
--env ANDROMEDA_TEMP_FOLDER=/tmp/andromeda \
--env SCRIPT_UUID=9ca7c005-1a6c-4908-9e37-4079e7c07991 \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
