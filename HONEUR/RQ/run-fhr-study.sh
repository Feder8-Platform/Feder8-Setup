#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=fhr-study
TAG=20250416

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run FHR study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name fhr-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=b781c3d2-a19b-4609-82d4-346a4991897e \
--network feder8-net \
-v $PWD/results/FHR:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "FHR study executed. Thank you!"

