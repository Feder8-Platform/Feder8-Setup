#!/usr/bin/env bash
set -ex

REGISTRY=harbor.honeur.org
REPOSITORY=library
IMAGE=etl-runner
VERSION=1.1.2
TAG=$VERSION

LOG_FOLDER_HOST=${PWD}/log
DATA_FOLDER_HOST=${PWD}/data
QA_FOLDER_HOST=${PWD}/qa

echo "Pull ETL runner image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

#echo "Download ETL questions"
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Relesser/questions.json --output questions.json

touch etl-runner.env
echo "THERAPEUTIC_AREA=lupus" >> etl-runner.env
echo "REGISTRY=harbor.lupusnet.org" >> etl-runner.env
echo "LOG_LEVEL=INFO" >> etl-runner.env
echo "LOG_FOLDER_HOST=$LOG_FOLDER_HOST" >> etl-runner.env
echo "LOG_FOLDER=/script/etl/relesser/log" >> etl-runner.env
echo "ETL_IMAGE_NAME=etl-relesser/etl" >> etl-runner.env
echo "ETL_IMAGE_TAG=latest" >> etl-runner.env
echo "DATA_FOLDER_HOST=$DATA_FOLDER_HOST" >> etl-runner.env
echo "DATA_FOLDER=/script/etl/data" >> etl-runner.env
echo "QA_FOLDER_HOST=$QA_FOLDER_HOST" >> etl-runner.env
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
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "End of ETL run"
rm -rf etl-runner.env

echo "Set permissions on new database schema's"
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;REASSIGN OWNED BY ohdsi_app_user TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_relesser_final TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_relesser_final TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_relesser_final TO ohdsi_admin;GRANT ALL ON ALL TABLES IN SCHEMA lupus_relesser_final TO ohdsi_admin;"

