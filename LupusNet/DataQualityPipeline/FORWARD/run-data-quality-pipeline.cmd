@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=distributed-analytics
SET IMAGE=data-quality-pipeline
SET VERSION=latest
SET TAG=%VERSION%
SET QA_FOLDER_HOST=%CD%/qa

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/DataQualityPipeline/FORWARD/lupus-lupus-pipeline.json --output lupus-lupus-pipeline.json

docker run --rm --name data-quality-pipeline --env REGISTRY=%REGISTRY% --env THERAPEUTIC_AREA=lupus --env INDICATION=lupus --env CDM_VERSION=5.4 --env QA_FOLDER_HOST=%QA_FOLDER_HOST% --env SCRIPT_UUID=82f80336-c3b7-4d09-b325-db8d2965fb86 -v %CD%/lupus-lupus-pipeline.json:/pipeline/lupus-lupus-pipeline.json -v /var/run/docker.sock:/var/run/docker.sock --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
