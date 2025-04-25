#!/usr/bin/env bash

docker pull harbor.lupusnet.org/lupus/postgres-omopcdm-update-custom-concepts-lupus:latest

docker run \
--rm \
--name omopcdm-update-custom-concepts \
-v shared:/var/lib/shared \
--network feder8-net \
harbor.lupusnet.org/lupus/postgres-omopcdm-update-custom-concepts-lupus:latest