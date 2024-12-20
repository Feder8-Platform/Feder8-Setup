#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=rq1
TAG=20241115

echo "Run RQ1"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name rq1 \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=3b7b2e33-c39f-4f22-ac23-b8ea93042097 \
--network feder8-net \
-v $PWD/results/RQ1:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "RQ1 executed. Thank you!"

