#!/usr/bin/env bash
set -e

read -p "Source data folder [${PWD}/data]: " data_folder
SOURCE_FOLDER=${data_folder:-${PWD}/data}
read -p "DB username [feder8_admin]: " db_username
DB_USER=${db_username:-feder8_admin}
read -p "DB password: " DB_PASSWORD

REGISTRY=harbor.lupusnet.org
REPOSITORY=etl-relesser

# Log into Harbor
echo "Login into Harbor (please enter your email address and Harbor CLI secret if needed)"
docker login $REGISTRY

# Run ETL
echo "Run ETL. Output will be written to: "
echo ${PWD}/qa
IMAGE=etl
TAG=latest

docker pull $REGISTRY/$REPOSITORY/$IMAGE:$TAG

docker run --rm --network feder8-net \
--env DB_USER=$DB_USER --env DB_PASSWORD=$DB_PASSWORD \
-v $SOURCE_FOLDER:/script/etl/data \
-v ${PWD}/qa:/script/etl/relesser/reports \
$REGISTRY/$REPOSITORY/$IMAGE:$TAG

echo "End of script"
echo "Please inspect and share the output under the following folder: "
echo ${PWD}/qa

