#!/usr/bin/env bash
set -e

read -p "Source data folder [${PWD}/data]: " data_folder
SOURCE_FOLDER=${data_folder:-${PWD}/data}
read -p "Source CSV file [gladel.csv]: " csv_file
SOURCE_CSV=${csv_file:-gladel.csv}
read -p "Source delimiter [;]: " src_delimiter
SOURCE_DELIMITER=${src_delimiter:-;}

REGISTRY=harbor.lupusnet.org
REPOSITORY=etl-gladel

echo "Login into Harbor (please enter your email address and Harbor CLI secret if needed)"
docker login $REGISTRY

echo "Pre-process source data"
IMAGE=src-data-pre-processor
TAG=1.0.0

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --name gladel-src-data-pre-processor \
--env SOURCE_CSV=$SOURCE_CSV \
--env SOURCE_DELIMITER="$SOURCE_DELIMITER" \
--env TARGET_DELIMITER="," \
-v $SOURCE_FOLDER:/script/data \
 $REGISTRY/$REPOSITORY/$IMAGE:$TAG

# Run ETL
REGISTRY=harbor.honeur.org
REPOSITORY=library
IMAGE=etl-runner
VERSION=1.1.2
TAG=$VERSION

LOG_FOLDER_HOST=${PWD}/log
DATA_FOLDER_HOST=$SOURCE_FOLDER
QA_FOLDER_HOST=${PWD}/qa

echo "Pull ETL runner image"
docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

#echo "Download ETL questions"
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Gladel/questions.json --output questions.json

touch etl-runner.env
echo "THERAPEUTIC_AREA=lupus" >> etl-runner.env
echo "REGISTRY=harbor.lupusnet.org" >> etl-runner.env
echo "LOG_LEVEL=INFO" >> etl-runner.env
echo "LOG_FOLDER_HOST=$LOG_FOLDER_HOST" >> etl-runner.env
echo "LOG_FOLDER=/script/etl/gladel/log" >> etl-runner.env
echo "ETL_IMAGE_NAME=etl-gladel/etl" >> etl-runner.env
echo "ETL_IMAGE_TAG=latest" >> etl-runner.env
echo "DATA_FOLDER_HOST=$DATA_FOLDER_HOST" >> etl-runner.env
echo "DATA_FOLDER=/script/etl/data" >> etl-runner.env
echo "QA_FOLDER_HOST=$QA_FOLDER_HOST" >> etl-runner.env
echo "QA_FOLDER_ETL=/script/etl/gladel/reports" >> etl-runner.env
echo "RUN_DQD=false" >> etl-runner.env
echo "LAST_DATA_EXPORT=2025-04-07" >> etl-runner.env

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
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;GRANT USAGE ON SCHEMA lupus_gladel_final TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_gladel_final TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_gladel_src TO ohdsi_app;GRANT ALL ON ALL TABLES IN SCHEMA lupus_gladel_src TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_gladel_etl TO ohdsi_app;GRANT ALL ON ALL TABLES IN SCHEMA lupus_gladel_etl TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_gladel_cdm TO ohdsi_app;GRANT ALL ON ALL TABLES IN SCHEMA lupus_gladel_cdm TO ohdsi_app;"
