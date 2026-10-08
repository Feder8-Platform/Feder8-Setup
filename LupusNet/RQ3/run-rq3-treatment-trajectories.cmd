@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=distributed-analytics
SET IMAGE=rq3-treatment-trajectories
SET TAG=1.5.1

echo "Docker login @ %REGISTRY%"
docker login %REGISTRY%

echo "Pull image"
docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --name rq3-treatment-trajectories --memory-swap -1 --env THERAPEUTIC_AREA=lupus --env SCRIPT_UUID=968a367f-d65e-4766-a7f1-03ef3ec0045f -v %CD%/results:/script/results --network feder8-net %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
