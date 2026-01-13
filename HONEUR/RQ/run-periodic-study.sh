#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_49
IMAGE=periodic-study
VERSION=V11
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

start=$(date +%s)

docker run --name periodic-study-$start \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=f6a75886-1242-43ce-a2fc-b3d61ee0fd8b \
-v $PWD/results:/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
