@ECHO off

SET TAG=2.2.4
SET REGISTRY=harbor.honeur.org

docker pull %REGISTRY%/library/install-script:%TAG%
docker run --rm -it --name feder8-installer -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init add-constraints-and-indexes
