#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq3-treatment-trajectories
TAG=1.0.0

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

mkdir -p $PWD/results

docker run --rm --name rq3-treatment-trajectories \
--memory-swap -1 \
--env THERAPEUTIC_AREA=lupus \
--env SCRIPT_UUID=57d9df9a-e063-45fc-9e70-556dc9e9f6d3 \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
