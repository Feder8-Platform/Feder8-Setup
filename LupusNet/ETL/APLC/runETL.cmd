@echo off

SET REGISTRY=harbor.honeur.org
SET REPOSITORY=library
SET IMAGE=etl-runner
SET VERSION=1.1.2
SET TAG=%VERSION%

SET LOG_FOLDER_HOST=%CD%/log
SET DATA_FOLDER_HOST=%CD%/data
SET QA_FOLDER_HOST=%CD%/qa

echo "Pull ETL runner image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

echo "Download ETL questions"
curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/APLC/questions.json --output questions.json

echo "Run ETL"
docker run -it --rm --name etl-runner --env THERAPEUTIC_AREA=lupus --env REGISTRY=harbor.lupusnet.org --env LOG_LEVEL=INFO --env LOG_FOLDER_HOST=%LOG_FOLDER_HOST% --env LOG_FOLDER=/script/etl/aplc/log --env ETL_IMAGE_NAME=etl-aplc/etl --env ETL_IMAGE_TAG=latest --env DATA_FOLDER_HOST=%DATA_FOLDER_HOST% --env DATA_FOLDER=/script/etl/data --env QA_FOLDER_HOST=%QA_FOLDER_HOST% --env QA_FOLDER_ETL=/script/etl/aplc/reports --env RUN_DQD=false -v /var/run/docker.sock:/var/run/docker.sock  -v %CD%/questions.json:/script/questions.json --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

echo "Set permissions on new database schema's"
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;GRANT USAGE ON SCHEMA lupus_aplc_final TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_aplc_final TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_aplc_cdm TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_aplc_cdm TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_aplc_src TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_aplc_src TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_aplc_etl TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_aplc_etl TO ohdsi_app;"

echo "End of ETL run"
echo "Please inspect and share the output under the following folder: "
echo %QA_FOLDER_HOST%
