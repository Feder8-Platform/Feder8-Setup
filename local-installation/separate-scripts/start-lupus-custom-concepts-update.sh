#!/usr/bin/env bash

docker pull harbor.lupusnet.org/lupus/postgres-omopcdm-update-custom-concepts-lupus:latest

docker run --rm --name omopcdm-update-lupus-custom-concepts \
--env DB_HOST=postgres --env DB_VOCAB_SCHEMA=omopcdm \
-v shared:/var/lib/shared \
--network feder8-net \
harbor.lupusnet.org/lupus/postgres-omopcdm-update-custom-concepts-lupus:latest