#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq3
TAG=1.0.0

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name lupusnet-rq3 \
--env THERAPEUTIC_AREA=lupus \
--env ORGANIZATION="gladel 1.0" \
--env SCRIPT_UUID=47441017-7c7a-4645-9751-f2c2bb1ddf60 \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
