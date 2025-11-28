#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=octogenarian
TAG=20250808

echo "Run Octogenarian study"

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name octogenarian-study \
--env THERAPEUTIC_AREA=HONEUR \
--env SCRIPT_UUID=341df45a-4c5c-41a8-a9d3-28506ee85922 \
--network feder8-net \
-v $PWD/results/Octogenarian:/script/results \
-v feder8-data:/home/feder8/data \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "Octogenarian study executed. Thank you!"

