@ECHO off

SET TAG=2.2.4
SET REGISTRY=harbor.honeur.org

SET DOCKER_HOST_CONFIG=172.17.0.1

docker pull %REGISTRY%/library/install-script:%TAG%
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -e DOCKER_CERT_SUPPORT=false -e DOCKER_HOST_CONFIG=%DOCKER_HOST_CONFIG% -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init full
