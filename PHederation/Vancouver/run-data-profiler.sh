#!/usr/bin/env bash
set -e

REGISTRY=harbor.phederation.org
REPOSITORY=distributed-analytics
IMAGE=data-profiler
VERSION=latest
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name data-profiler \
-v ${PWD}/data_profiler_results:/script/data_profiler_results \
--env THERAPEUTIC_AREA=PHEDERATION \
--env INDICATION=ph \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
