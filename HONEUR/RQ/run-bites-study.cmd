@ECHO off

SET REGISTRY=harbor.honeur.org
SET REPOSITORY=script
SET IMAGE=bites-study
SET VERSION=20260601
SET TAG=%VERSION%

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull Docker image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --name bites-study --env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table --env SCRIPT_UUID=612a7247-5852-418f-895a-972b7e89a394 -v "%CD%/results/bites":/script/results -v feder8-data:/home/feder8/data --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
