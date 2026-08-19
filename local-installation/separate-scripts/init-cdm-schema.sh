#!/usr/bin/env bash
set -e

REGISTRY=harbor.honeur.org
REPOSITORY=honeur
IMAGE=postgres-omopcdm-initialize-schema
TAG=2.0.3

read -rp "Enter CDM_VERSION (5.3.1 or 5.4) [5.4]: " CDM_VERSION
CDM_VERSION=${CDM_VERSION:-5.4}
if [[ "$CDM_VERSION" != "5.3.1" && "$CDM_VERSION" != "5.4" ]]; then
    echo "Error: CDM_VERSION must be 5.3.1 or 5.4" >&2
    exit 1
fi

read -rp "Enter SCHEMA name [omopcdm_54]: " SCHEMA
SCHEMA=${SCHEMA:-omopcdm_54}
if [[ ! "$SCHEMA" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
    echo "Error: SCHEMA must be a valid PostgreSQL identifier (letters, digits, underscores; cannot start with a digit)" >&2
    exit 1
fi

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
