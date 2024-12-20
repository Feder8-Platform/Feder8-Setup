#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=octogenarian
TAG=20241203

echo "Run Octogenarian study"

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name octogenarian-study \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=a6e73864-6831-4c29-8f2b-330c8828954d \
--network feder8-net \
-v $PWD/results/Octogenarian:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "Octogenarian study executed. Thank you!"

