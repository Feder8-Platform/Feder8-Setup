#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=honeur
IMAGE=postgres-omopcdm-initialize-schema
TAG=2.0.3
CDM_VERSION=5.3.1 # 5.3.1 or 5.4
SCHEMA=omopcdm_53_test

docker login $REGISTRY

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run \
--rm \
--name omopcdm-initialize-schema \
-v shared:/var/lib/shared \
--env CDM_VERSION=$CDM_VERSION --env DB_OMOPCDM_SCHEMA=$SCHEMA \
--env FEDER8_ADMIN_USERNAME=feder8_admin \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;REASSIGN OWNED BY ohdsi_admin_user TO ohdsi_admin;"
