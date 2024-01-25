#!/usr/bin/env bash
set -ex

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=analysis-table-generator-lupus
VERSION=latest
TAG=$VERSION

echo "Docker login @ $REGISTRY"
docker login $REGISTRY

echo "Pull image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run \
--rm \
--name analysis-table-generator \
--env THERAPEUTIC_AREA=lupus \
--env DB_ANALYSIS_TABLE_NAME=analysis_table \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
