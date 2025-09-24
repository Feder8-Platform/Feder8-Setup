@ECHO off

SET REGISTRY=harbor.honeur.org
SET REPOSITORY=script
SET IMAGE=bites-study
SET VERSION=20250915
SET TAG=%VERSION%

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull Docker image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --name bites-study --env THERAPEUTIC_AREA=HONEUR --env DB_ANALYSIS_TABLE_NAME=analysis_table --env SCRIPT_UUID=6327f043-f81a-45e2-8dcf-6cc7faf96e34 -v "%CD%/results/bites":/script/results -v feder8-data:/home/feder8/data --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
