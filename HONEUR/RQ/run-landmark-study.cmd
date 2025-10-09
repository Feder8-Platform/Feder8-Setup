@ECHO off

SET REGISTRY=harbor.honeur.org
SET REPOSITORY=study_36
SET IMAGE=landmark-study
SET VERSION=V11
SET TAG=%VERSION%

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull Docker image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --name landmark-study --env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=74a5aa6f-ef7e-4a13-8f4e-63c9a3beef36 -v "%CD%/results":/script/results -v feder8-data:/home/feder8/data --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

