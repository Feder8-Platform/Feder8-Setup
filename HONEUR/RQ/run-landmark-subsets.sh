#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=distributed-analytics
IMAGE=landmark-subsets
VERSION=20260506
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name landmark-study-subsets \
--network feder8-net \
--env THERAPEUTIC_AREA=HONEUR \
-v feder8-data:/home/feder8/data \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
