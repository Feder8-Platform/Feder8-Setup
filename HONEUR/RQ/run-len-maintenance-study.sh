#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=len-maintenance-study
VERSION=20250805
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name len-maintenance-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=189a1d9a-1d27-4dc0-b26f-f01476d6762b \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
