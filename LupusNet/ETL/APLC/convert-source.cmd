@ECHO off

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=etl-aplc
SET IMAGE=src-converter
SET VERSION=1.0.0
SET TAG=%VERSION%

docker login %REGISTRY%

docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --env INPUT_FOLDER=/script/input --env INPUT_FILE=/script/input/aplc.csv -v %CD%/data:/script/input %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
