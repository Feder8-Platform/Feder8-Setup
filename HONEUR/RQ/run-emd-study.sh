#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=emd-study
TAG=20250417

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run EMD study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name emd-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=cf90f1e1-5cb4-4c70-b380-8278c1e5b950 \
--network feder8-net \
-v $PWD/results/EMD:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "EMD study executed. Thank you!"

