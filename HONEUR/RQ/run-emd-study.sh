#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_47
IMAGE=emd-study
TAG=V5

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run EMD study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name emd-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=d25c3551-96cf-43e0-a2ba-a4aeb90d975f \
--network feder8-net \
-v $PWD/results/EMD:/script/results \
-v feder8-data:/home/feder8/data \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "EMD study executed. Thank you!"

