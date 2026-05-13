#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_47
IMAGE=emd-study
TAG=V4

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run EMD study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name emd-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=5799a23f-6945-4dd1-b481-e5d4b092ed00 \
--network feder8-net \
-v $PWD/results/EMD:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "EMD study executed. Thank you!"

