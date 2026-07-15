#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=honeur
VERSION=2.0.2
OMOP_CDM_VERSION="${OMOP_CDM_VERSION:-5.3.1}"
TAG=$OMOP_CDM_VERSION-$VERSION



echo "DB_HOST=postgres" >>  omopcdm-add-constraints.env

docker run \
--rm \
--name  omopcdm-add-constraints \
-v shared:/var/lib/shared \
--env-file  omopcdm-add-constraints.env \
--network feder8-net \
feder8/postgres-omopcdm-add-constraints:$TAG

rm -rf  omopcdm-add-constraints.env
