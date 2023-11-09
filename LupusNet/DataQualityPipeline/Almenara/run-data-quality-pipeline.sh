#!/usr/bin/env bash
set -ex

REGISTRY=harbor.lupusnet.org
REPOSITORY=distributed-analytics
IMAGE=data-quality-pipeline
VERSION=1.6
TAG=$VERSION

echo "Docker login @ $REGISTRY"
docker login $REGISTRY
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

QA_FOLDER_HOST=${PWD}/qa

touch data-quality-pipeline.env
echo "REGISTRY=$REGISTRY" >> data-quality-pipeline.env
echo "THERAPEUTIC_AREA=lupus" >> data-quality-pipeline.env
echo "INDICATION=lupus" >> data-quality-pipeline.env
echo "CDM_VERSION=5.4"  >> data-quality-pipeline.env
echo "QA_FOLDER_HOST=$QA_FOLDER_HOST" >> data-quality-pipeline.env
echo "SCRIPT_UUID=82f80336-c3b7-4d09-b325-db8d2965fb86" >> data-quality-pipeline.env

docker run \
--rm \
--name data-quality-pipeline \
--env-file data-quality-pipeline.env \
-v /var/run/docker.sock:/var/run/docker.sock \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

rm -rf data-quality-pipeline.env
