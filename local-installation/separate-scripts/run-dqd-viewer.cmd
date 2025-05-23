@ECHO off

SET TAG=1.0
SET REGISTRY=harbor.honeur.org
SET REPOSITORY=honeur
SET IMAGE=dqd-viewer

set /p FILE_PATH=Please enter the path of your DQD: 

docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
docker run --rm --name dqd-viewer -v %FILE_PATH%:/dqd/dqd.json -p 3838:3838 --network feder8-net $REGISTRY/$REPOSITORY/$IMAGE:$TAG