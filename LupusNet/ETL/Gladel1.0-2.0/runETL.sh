#!/usr/bin/env bash
set -e

#############
## RUN ETL ##
#############
REGISTRY_ETL_RUNNER=harbor.honeur.org
REPOSITORY_ETL_RUNNER=library
IMAGE_ETL_RUNNER=etl-runner
VERSION_ETL_RUNNER=1.1.4
TAG_ETL_RUNNER=$VERSION_ETL_RUNNER

LOG_FOLDER_HOST=${PWD}/log
DATA_FOLDER_HOST=${PWD}/data
QA_FOLDER_HOST=${PWD}/qa

echo "Pull ETL runner image"
docker pull $REGISTRY_ETL_RUNNER/$REPOSITORY_ETL_RUNNER/$IMAGE_ETL_RUNNER:$TAG_ETL_RUNNER

REGISTRY=harbor.lupusnet.org
REPOSITORY=etl-gladel-2.0

# Log into Harbor
echo "Login into Harbor (please enter your email address and Harbor CLI secret if needed)"
docker login $REGISTRY

#echo "Download ETL questions"
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Gladel1.0-2.0/questions.json --output questions.json

touch etl-runner.env
# etl image
echo "THERAPEUTIC_AREA=lupus" >> etl-runner.env
echo "REGISTRY=$REGISTRY" >> etl-runner.env
echo "ETL_IMAGE_NAME=$REPOSITORY/etl" >> etl-runner.env
echo "ETL_IMAGE_TAG=current" >> etl-runner.env
# logs
echo "LOG_FOLDER_HOST=${PWD}/log" >> etl-runner.env
echo "LOG_FOLDER=/log" >> etl-runner.env
# source data
echo "DATA_FOLDER=/source" >> etl-runner.env
echo "SOURCE_RELEASE_DATE=$SOURCE_RELEASE_DATE" >> etl-runner.env
echo "ENCODING=utf-8" >> etl-runner.env
echo "FILE_TYPE=csv" >> etl-runner.env
# QA and DQD
echo "QA_FOLDER_HOST=$QA_FOLDER_HOST" >> etl-runner.env
echo "QA_FOLDER_ETL=/script/etl/gladel/reports" >> etl-runner.env
echo "RUN_DQD=false" >> etl-runner.env

echo "Run ETL"
docker run \
-it \
--rm \
--name etl-runner \
--env-file etl-runner.env \
-v /var/run/docker.sock:/var/run/docker.sock \
-v ${PWD}/questions.json:/script/questions.json \
--network feder8-net \
$REGISTRY_ETL_RUNNER/$REPOSITORY_ETL_RUNNER/$IMAGE_ETL_RUNNER:$TAG_ETL_RUNNER

echo "End of ETL run"
rm -rf etl-runner.env

echo "Set permissions on new database schema's"
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;GRANT USAGE ON SCHEMA omopcdm TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA omopcdm TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_gladel_src TO ohdsi_app;GRANT ALL ON ALL TABLES IN SCHEMA lupus_gladel_src TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_gladel_etl TO ohdsi_app;GRANT ALL ON ALL TABLES IN SCHEMA lupus_gladel_etl TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_gladel_cdm TO ohdsi_app;GRANT ALL ON ALL TABLES IN SCHEMA lupus_gladel_cdm TO ohdsi_app;"
