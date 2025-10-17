#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq2-feasibility
TAG=1.5.10

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker rm -f lupusnet-rq2-feasibility 2>/dev/null || true

docker run --name lupusnet-rq2-feasibility \
--env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=d0f988fc-38de-4cec-b6c9-40653e9c240a \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
