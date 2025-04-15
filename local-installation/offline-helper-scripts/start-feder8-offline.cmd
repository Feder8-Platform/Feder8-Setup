@ECHO off

SET TAG=2.2.3
SET PYTHON_VERSION=3.11
SET REGISTRY=harbor.honeur.org

SET THERAPEUTIC_AREA_JSON_PATH=/usr/local/lib/python3.11/site-packages/feder8-%TAG%-py%PYTHON_VERSION%.egg/cli/therapeutic_area/therapeutic-areas.json
SET FEDER8_LOCAL_IMAGE_JSON_PATH=/usr/local/lib/python3.11/site-packages/feder8-%TAG%-py%PYTHON_VERSION%.egg/cli/configuration/feder8-local-images.json

docker logout %REGISTRY%

if exist images.tar (
    if exist therapeutic-areas.json (
        if exist feder8-local-images.json (
            echo Loading docker images. This could take a while...
            docker load -i images.tar
            docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -e DOCKER_CERT_SUPPORT=false -v ./therapeutic-areas.json:%THERAPEUTIC_AREA_JSON_PATH% -v ./feder8-local-images.json:%FEDER8_LOCAL_IMAGE_JSON_PATH% -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init --offline full
        )
    )
) else (
    echo Could not find 'images.tar', 'therapeutic-areas.json' and/or 'feder8-local-images.json' in the current directory. Unable to continue.
    exit 1
)
