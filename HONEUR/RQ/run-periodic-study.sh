#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=periodic-study
VERSION=20250523
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

start=$(date +%s)

docker run --rm --name periodic-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=8e3be610-1109-42f7-aa58-2439c85abdab \
-v $PWD/results:/script/results \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
