#!/usr/bin/env bash
set -e

read -p "Source data folder [${PWD}/data]: " data_folder
SOURCE_FOLDER=${data_folder:-${PWD}/data}
read -p "Source CSV file [gladel.csv]: " csv_file
SOURCE_CSV=${csv_file:-gladel.csv}
read -p "DB username [lupus_admin]: " db_username
DB_USER=${db_username:-lupus_admin}
read -p "DB password: " DB_PASSWORD

REGISTRY=harbor.lupusnet.org
REPOSITORY=etl-gladel

# Log into Harbor
echo "Login into Harbor (please enter your email address and Harbor CLI secret if needed)"
docker login $REGISTRY

# Split source CSV in chunks
echo "Split source CSV file into smaller chunks"
IMAGE=gladel-csv-splitter
VERSION=1.0.0
TAG=$VERSION

touch gladel-csv-splitter.env
echo "SOURCE_CSV=$SOURCE_CSV" >> gladel-csv-splitter.env
echo "TARGET_CSV_PREFIX=gladel" >> gladel-csv-splitter.env

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run \
--rm \
--name gladel-csv-splitter \
--env-file gladel-csv-splitter.env \
-v $SOURCE_FOLDER:/script/data \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

rm -rf gladel-csv-splitter.env

# Run ETL
echo "Run ETL. Output will be written to: "
echo ${PWD}/qa
IMAGE=etl
TAG=latest

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm -it --network feder8-net \
--env DB_USER=$DB_USER --env DB_PASSWORD=$DB_PASSWORD \
-v $SOURCE_FOLDER:/script/etl/data \
-v ${PWD}/qa:/script/etl/gladel/reports \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "End of script"
echo "Please inspect and share the output under the following folder: "
echo ${PWD}/qa

