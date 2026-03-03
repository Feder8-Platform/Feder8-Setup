#!/usr/bin/env bash

TAG=2.3.1
REGISTRY=harbor.honeur.org

docker pull ${REGISTRY}/library/install-script:${TAG}

docker exec -it postgres psql -U postgres -d OHDSI -c "
ALTER TABLE results.patient_check DROP CONSTRAINT IF EXISTS fpk_patient_check_concept1;
ALTER TABLE results.patient_check DROP CONSTRAINT IF EXISTS fpk_patient_check_concept2;
"

docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=$(pwd) -e IS_WINDOWS=false -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock -v ./info_feder8_installation:/opt/install-script/info_feder8_installation ${REGISTRY}/library/install-script:${TAG} feder8 init update-vocabulary