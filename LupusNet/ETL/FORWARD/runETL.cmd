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

curl -fsSL https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/FORWARD/questions.json --output questions.json

echo "Run ETL"
docker run -it --rm --name etl-runner --network feder8-net --env THERAPEUTIC_AREA=lupus --env REGISTRY=harbor.lupusnet.org --env LOG_LEVEL=INFO --env LOG_FOLDER_HOST=%LOG_FOLDER_HOST% --env LOG_FOLDER=/script/etl/forward/log --env ETL_IMAGE_NAME=etl-forward/etl --env ETL_IMAGE_TAG=latest --env DATA_FOLDER_HOST=%DATA_FOLDER_HOST% --env DATA_FOLDER=/script/etl/data --env QA_FOLDER_HOST=%QA_FOLDER_HOST% --env QA_FOLDER_ETL=/script/etl/forward/reports --env RUN_DQD=false -v /var/run/docker.sock:/var/run/docker.sock -v %CD%/questions.json:/script/questions.json %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

echo "End of ETL run"