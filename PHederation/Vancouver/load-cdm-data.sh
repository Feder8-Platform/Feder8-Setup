#!/usr/bin/env bash
set -ex

REGISTRY=harbor.phederation.org
REPOSITORY=phederation
IMAGE=postgres-omopcdm-loader
VERSION=1.0.0
TAG=$VERSION

echo "Login into $REGISTRY"
docker login $REGISTRY

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

# --env DB_OMOPCDM_SCHEMA=omopcdm
# --env DELIMITER=,
# --env ENCODING=latin-1

docker run --rm --name omopcdm-loader \
-v shared:/var/lib/shared \
-v $PWD/data:/script/data \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG
