#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_49
IMAGE=periodic-study-ash26
VERSION=V3
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

start=$(date +%s)

docker run --name periodic-study-ash26-$start \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=f9bb91b8-20b9-45c5-94dd-8269ce529358 \
-v $PWD/results:/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
