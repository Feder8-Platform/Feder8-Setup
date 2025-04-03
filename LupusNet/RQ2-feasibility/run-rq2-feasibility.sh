#!/usr/bin/env bash
set -eux

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=rq2-feasibility
TAG=1.4.1

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name lupusnet-rq2-feasibility \
--env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=3a535076-e88f-4b2a-9236-214426ed38f7 \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
