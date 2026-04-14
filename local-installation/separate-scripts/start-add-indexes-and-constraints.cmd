@ECHO off

SET TAG=2.3.1
SET REGISTRY=harbor.honeur.org

docker pull %REGISTRY%/library/install-script:%TAG%
docker run --rm -it --name feder8-installer -v /var/run/docker.sock:/var/run/docker.sock -v %CD%/info_feder8_installation:/opt/install-script/info_feder8_installation %REGISTRY%/library/install-script:%TAG% feder8 init add-constraints-and-indexes
