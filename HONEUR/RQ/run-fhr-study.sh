#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=fhr-study
TAG=20250417

echo "Log in to Harbor"
docker login $REGISTRY

echo "Run FHR study"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name fhr-study \
--env THERAPEUTIC_AREA=HONEUR \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=771f82a5-99df-4650-a528-7b216dd7782b \
--network feder8-net \
-v $PWD/results/FHR:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "FHR study executed. Thank you!"

