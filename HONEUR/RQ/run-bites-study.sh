#!/usr/bin/env bash
set -eux

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=bites-study
VERSION=20251008
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name bites-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=9e9649a5-93b7-47e9-9425-d92a02a2304f \
-v "$PWD/results/bites":/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
