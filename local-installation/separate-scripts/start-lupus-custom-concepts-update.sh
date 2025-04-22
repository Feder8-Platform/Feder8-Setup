#!/usr/bin/env bash

docker pull harbor.lupusnet.org/lupus/postgres-omopcdm-update-custom-concepts-lupus:latest

touch omopcdm-update-custom-concepts.env

echo "DB_HOST=postgres" >> omopcdm-update-custom-concepts.env
echo "DB_PORT=5432" >> omopcdm-update-custom-concepts.env
echo "DB_DATABASE_NAME=OHDSI" >> omopcdm-update-custom-concepts.env
echo "DB_OMOPCDM_SCHEMA=omopcdm54" >> omopcdm-update-custom-concepts.env

docker run \
--rm \
--name omopcdm-update-custom-concepts \
-v shared:/var/lib/shared \
--env-file omopcdm-update-custom-concepts.env \
--network feder8-net \
harbor.lupusnet.org/lupus/postgres-omopcdm-update-custom-concepts-lupus:latest

rm -rf omopcdm-update-custom-concepts.env