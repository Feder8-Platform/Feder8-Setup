#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script
IMAGE=periodic-study
VERSION=20250611
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "" >> $PWD/logofcode.txt

start=$(date +%s)

docker run --name periodic-study \
--env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table \
--env SCRIPT_UUID=d93f641f-3fff-427b-8aad-f06cd6e9a3d8 \
-v $PWD/results:/script/results \
-v $PWD/logofcode.txt:/script/logofcode.txt \
-v feder8-data:/home/feder8/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

end=$(date +%s)
duration=$(( end - start ))
echo "Duration: ${duration} seconds"
