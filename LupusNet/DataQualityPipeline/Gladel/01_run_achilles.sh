#!/usr/bin/env bash
set -ex

TAG=latest

touch achilles.env

echo "DB_HOST=postgres" >> achilles.env
echo "DB_DATABASE_NAME=OHDSI" >> achilles.env
echo "FEDER8_CDM_SCHEMA=omopcdm" >> achilles.env
echo "FEDER8_VOCABULARY_SCHEMA=omopcdm" >> achilles.env
echo "FEDER8_RESULTS_SCHEMA=results" >> achilles.env
echo "WEBAPI_SOURCE_NAME=?" >> achilles.env
echo "CDM_VERSION=5.4" >> achilles.env
echo "THERAPEUTIC_AREA=LUPUS" >> achilles.env


docker run \
--rm \
--name achilles \
-v shared:/var/lib/shared \
-v ${PWD}/achilles-logs:/logs \
--env-file achilles.env \
--network feder8-net \
harbor.lupusnet.org/distributed-analytics/achilles:$TAG

rm -rf achilles.env
