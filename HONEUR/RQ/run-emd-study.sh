#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=emd-study
TAG=20250523

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run EMD study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name emd-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=5dccfc57-1725-4d4f-bc33-ec0423916954 \
--network feder8-net \
-v $PWD/results/EMD:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "EMD study executed. Thank you!"

