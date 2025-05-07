@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=distributed-analytics
SET IMAGE=rq2-feasibility
SET TAG=1.4.5

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --name lupusnet-rq2-feasibility --env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=cefacdeb-5374-4319-81f8-f6627b3567ca -v %CD%/results:/script/results --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
