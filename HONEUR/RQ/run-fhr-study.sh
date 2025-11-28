#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=fhr-study
TAG=20250808

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run FHR study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name fhr-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=5d0b97fc-c270-4255-be32-48628165cbdc \
--network feder8-net \
-v $PWD/results/FHR:/script/results \
-v feder8-data:/home/feder8/data \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "FHR study executed. Thank you!"

