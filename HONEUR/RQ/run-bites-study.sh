#!/usr/bin/env bash
set -eux

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=bites-study
VERSION=20260601
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name bites-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=612a7247-5852-418f-895a-972b7e89a394 \
-v "$PWD/results/bites":/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
