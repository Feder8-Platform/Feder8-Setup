#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq3-treatment-trajectories
TAG=1.5.1

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

mkdir -p $PWD/results

docker run --rm --name rq3-treatment-trajectories \
--memory-swap -1 \
--env THERAPEUTIC_AREA=lupus \
--env ORGANIZATION="gladel 1.0" \
--env SCRIPT_UUID=968a367f-d65e-4766-a7f1-03ef3ec0045f \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
