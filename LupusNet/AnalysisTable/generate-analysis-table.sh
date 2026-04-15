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

docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;GRANT USAGE ON SCHEMA results TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA results TO ohdsi_app;"

