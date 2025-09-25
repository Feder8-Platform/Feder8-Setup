#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=emd-feasibility
TAG=20250925

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run EMD feasibility"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name emd-feasibility \
--env THERAPEUTIC_AREA=HONEUR \
--env SCRIPT_UUID=f45d86a7-8f2b-4ca6-bc33-2568aed2d8d4 \
--network feder8-net \
-v $PWD/results/EMD:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "EMD feasibility executed. Thank you!"

