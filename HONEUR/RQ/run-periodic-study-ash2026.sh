#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=study_49
IMAGE=periodic-study-ash26
VERSION=V1
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

start=$(date +%s)

docker run --name periodic-study-ash26-$start \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=214521eb-7f2c-4516-8969-17f4d354a673 \
-v $PWD/results:/script/results \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
