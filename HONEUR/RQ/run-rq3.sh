#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=rq3
TAG=20241122

echo "Run RQ3"

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name rq3 \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=e0b8ad6f-58dd-404e-ae2b-1fda2201896a \
--network feder8-net \
-v $PWD/results/RQ3:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "RQ3 executed. Thank you!"

