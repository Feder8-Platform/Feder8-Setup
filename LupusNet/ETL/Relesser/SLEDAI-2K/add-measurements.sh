#!/usr/bin/env bash
set -ex

curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Relesser/SLEDAI-2K/LupusNet-RELESSER-add-SLEDAI-2K.sql --output LupusNet-RELESSER-add-SLEDAI-2K.sql

cat LupusNet-RELESSER-add-SLEDAI-2K.sql | docker exec -i postgres psql -U postgres -d OHDSI
