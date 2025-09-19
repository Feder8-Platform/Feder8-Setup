@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=distributed-analytics
SET IMAGE=rq2-feasibility
SET TAG=1.5.7

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --name lupusnet-rq2-feasibility --env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=9a543ab9-530a-49d9-8bd2-c62a8732c90c -v %CD%/results:/script/results --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
