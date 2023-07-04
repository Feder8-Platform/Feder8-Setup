@ECHO off

SET TAG=2.0.23
SET REGISTRY=harbor.honeur.org

echo "Pull latest local installation script"
docker pull %REGISTRY%/library/install-script:%TAG%
echo "Upgrade local portal"
docker run --rm -it --name feder8-installer -e IS_WINDOWS=true -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init local-portal
echo "Upgrade NGINX"
docker run --rm -it --name feder8-installer -e IS_WINDOWS=true -e CURRENT_DIRECTORY=%CD% -e FEDER8_HOST_HTTP_PORT=8080 -e FEDER8_HOST_HTTPS_PORT=8443 -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init nginx