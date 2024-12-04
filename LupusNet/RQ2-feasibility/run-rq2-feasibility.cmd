@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=distributed-analytics
SET IMAGE=rq2-feasibility
SET TAG=1.1.0

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --name lupusnet-rq2-feasibility --env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=f8d58350-5cd2-45c4-8f7f-e28fc66c810b -v %CD%/results:/script/results --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
