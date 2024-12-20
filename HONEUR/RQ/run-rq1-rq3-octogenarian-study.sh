#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=script

echo "Run RQ1"
IMAGE=rq1
TAG=20241115
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name rq1 \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=3b7b2e33-c39f-4f22-ac23-b8ea93042097 \
--network feder8-net \
-v $PWD/results/RQ1:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "Run RQ3"
IMAGE=rq3
TAG=20241122
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name rq3 \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=e0b8ad6f-58dd-404e-ae2b-1fda2201896a \
--network feder8-net \
-v $PWD/results/RQ3:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "Run Octogenarian study"
IMAGE=octogenarian
TAG=20241203
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run --rm --name octogenarian-study \
--env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=a6e73864-6831-4c29-8f2b-330c8828954d \
--network feder8-net \
-v $PWD/results/Octogenarian:/script/results \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "RQ1, RQ3 and Octogenarian study executed. Thank you!"

