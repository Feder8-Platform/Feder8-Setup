@ECHO off

SET TAG=2.2.5
SET REGISTRY=harbor.honeur.org

set "ORGANIZATION="
set /p "ORGANIZATION=Enter organization name:"

docker pull %REGISTRY%/library/install-script:%TAG%
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init full --non_interactive --distributed_analytics --organization=%ORGANIZATION%