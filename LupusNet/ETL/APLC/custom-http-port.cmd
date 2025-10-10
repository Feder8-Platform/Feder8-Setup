@ECHO off

SET TAG=2.2.5
SET REGISTRY=harbor.honeur.org
SET DOCKER_HOST_CONFIG=172.17.0.1

echo "Pull latest local installation script"
docker pull %REGISTRY%/library/install-script:%TAG%

echo "Update local installation to run on a custom HTTP port (8080)"
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -e DOCKER_CERT_SUPPORT=false -e DOCKER_HOST_CONFIG=%DOCKER_HOST_CONFIG% -e FEDER8_HOST_HTTP_PORT=8080 -e FEDER8_HOST_HTTPS_PORT=8443 -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init full
