#!/usr/bin/env bash
set -eux

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=bites-study
VERSION=20260416
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name bites-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=f5386fc0-eafb-4a2d-ad97-c4f1789896e9 \
-v "$PWD/results/bites":/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
