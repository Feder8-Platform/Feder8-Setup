@ECHO off

SET TAG=2.3.3
SET REGISTRY=harbor.honeur.org
docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock -v %CD%/info_feder8_installation:/opt/install-script/info_feder8_installation %REGISTRY%/library/install-script:%TAG% feder8 init restore
