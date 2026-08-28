#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_49
IMAGE=periodic-study-ash26
VERSION=V4
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

start=$(date +%s)

docker run --name periodic-study-ash26-$start \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=27e7b467-8096-4f30-889f-c192a89dd48a \
-v $PWD/results:/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
