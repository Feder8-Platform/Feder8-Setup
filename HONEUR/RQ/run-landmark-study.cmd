@ECHO off

SET REGISTRY=harbor.honeur.org
SET REPOSITORY=study_36
SET IMAGE=landmark-study
SET VERSION=V14
SET TAG=%VERSION%

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull Docker image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

type nul > "%CD%\logofcode.txt"

docker run --rm --name landmark-study --env THERAPEUTIC_AREA=HONEUR --env SCRIPT_UUID=683b559f-189f-4414-b212-04551987717b -v "%CD%/logofcode.txt":/script/logofcode.txt -v "%CD%/results":/script/results -v feder8-data:/home/feder8/data --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

