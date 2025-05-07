#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq2-feasibility
TAG=1.4.5

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name lupusnet-rq2-feasibility \
--env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=cefacdeb-5374-4319-81f8-f6627b3567ca \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
