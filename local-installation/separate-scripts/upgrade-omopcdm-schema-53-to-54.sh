#!/usr/bin/env bash
set -e

CDM_SCHEMA=omopcdm
RENAMED_CDM_SHEMA=omopcdm53
NEW_CDM_SCHEMA=omopcdm

echo "Rename existing omopcdm schema to $RENAMED_CDM_SHEMA"
docker exec -it postgres psql -U postgres -d OHDSI -c "ALTER SCHEMA $CDM_SCHEMA RENAME TO $RENAMED_CDM_SHEMA"

echo "Initialize $NEW_CDM_SCHEMA schema"
REGISTRY=harbor.honeur.org
REPOSITORY=honeur
IMAGE=postgres-omopcdm-initialize-schema
TAG=2.0.3

echo "Logging in $REGISTRY..."
docker login $REGISTRY

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG
docker run \
--rm \
--name omopcdm-initialize-schema \
-v shared:/var/lib/shared \
--env DB_HOST=postgres --env CDM_VERSION=5.4 \
--env DB_OMOPCDM_SCHEMA=$NEW_CDM_SCHEMA --env FEDER8_ADMIN_USERNAME=feder8_admin \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "Set ownership of $NEW_CDM_SCHEMA schema"
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;REASSIGN OWNED BY ohdsi_admin_user TO ohdsi_admin;"

echo "Load vocabularies in $NEW_CDM_SCHEMA"
TAG=2.1.4
docker pull ${REGISTRY}/library/install-script:${TAG}
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY="$(pwd)" -e IS_WINDOWS=false -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock ${REGISTRY}/library/install-script:${TAG} feder8 init update-vocabulary -ta honeur



