#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=emd-study
TAG=20250414

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run EMD study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name emd-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=a466bad7-0f22-4012-8451-1cffce92b41d \
--network feder8-net \
-v $PWD/results/EMD:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "EMD study executed. Thank you!"

