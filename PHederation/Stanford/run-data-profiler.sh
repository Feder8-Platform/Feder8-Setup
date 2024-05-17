#!/usr/bin/env bash
set -e

REGISTRY=harbor.phederation.org
REPOSITORY=distributed-analytics
IMAGE=data-profiler
VERSION=latest
TAG=$VERSION

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

touch data-profiler.env
echo "THERAPEUTIC_AREA=PHEDERATION" >> data-profiler.env
echo "INDICATION=ph" >> data-profiler.env
echo "DB_CDM_SCHEMA=omopcdm" >> data-profiler.env
echo "DB_VOCABULARY_SCHEMA=omopcdm" >> data-profiler.env
echo "LOG_LEVEL=INFO" >> data-profiler.env
echo "BIGQUERY_PROJECT_ID=feder8-407214" >> data-profiler.env
echo "GOOGLE_APPLICATION_CREDENTIALS=/auth/bq/application_default_credentials.json" >> data-profiler.env

# -v $HOME/.config/gcloud/application_default_credentials.json:/auth/bq/application_default_credentials.json \

docker run \
--rm \
--name data-profiler \
-v ${PWD}/data_profiler_results:/script/data_profiler_results \
-v feder8-bq-sa:/auth/bq \
--env-file data-profiler.env \
--network feder8-net \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

rm -rf data-profiler.env
