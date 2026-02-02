@ECHO off

SET REGISTRY=harbor.honeur.org
SET REPOSITORY=script
SET IMAGE=landmark-study
SET VERSION=20260202
SET TAG=%VERSION%

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull Docker image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

type nul > "%CD%\logofcode.txt"

docker run --rm --name landmark-study --env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=9d91de06-c135-4eaf-b0ec-ae3ab3dc6c74 -v "%CD%/logofcode.txt":/script/logofcode.txt -v "%CD%/results":/script/results -v feder8-data:/home/feder8/data --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

