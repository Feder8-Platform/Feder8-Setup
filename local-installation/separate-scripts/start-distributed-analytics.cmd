@ECHO off

SET TAG=2.3.0
SET REGISTRY=harbor.honeur.org

set "ORGANIZATION="
set /p "ORGANIZATION=Enter organization name:"

docker pull %REGISTRY%/library/install-script:%TAG%
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -v /var/run/docker.sock:/var/run/docker.sock -v ./info_feder8_installation:/usr/local/lib/python3.11/site-packages/feder8-%TAG%-py3.11.egg/cli/info_feder8_installation %REGISTRY%/library/install-script:%TAG% feder8 init full --non_interactive --distributed_analytics --organization=%ORGANIZATION%