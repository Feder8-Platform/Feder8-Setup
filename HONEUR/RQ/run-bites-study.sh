#!/usr/bin/env bash
set -eux

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=bites-study
VERSION=20250808
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name bites-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=27067510-c75e-4b0d-a0a3-751fd8854581 \
-v "$PWD/results":/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
