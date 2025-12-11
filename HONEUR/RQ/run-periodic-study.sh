#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_49
IMAGE=periodic-study
VERSION=V10
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

start=$(date +%s)

docker run --name periodic-study-$start \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=4235a4bc-5aca-4fd7-a9a9-6406d1f894a2 \
-v $PWD/results:/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
