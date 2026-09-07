@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=distributed-analytics
SET IMAGE=rq3-treatment-trajectories
SET TAG=1.0.0

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --name rq3-treatment-trajectories --memory-swap -1 --env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=57d9df9a-e063-45fc-9e70-556dc9e9f6d3 -v %CD%/results:/script/results --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
