@ECHO off

SET TAG=2.2.4
SET REGISTRY=harbor.honeur.org

docker pull %REGISTRY%/library/install-script:%TAG%

docker exec -it postgres psql -U postgres -d OHDSI -c "ALTER TABLE results.patient_check DROP CONSTRAINT IF EXISTS fpk_patient_check_concept1;ALTER TABLE results.patient_check DROP CONSTRAINT IF EXISTS fpk_patient_check_concept2;"

docker run --rm -it --name feder8-installer -e CURRENT_DIRECTORY=%CD% -e IS_WINDOWS=true -e IS_MAC=false -e DOCKER_CERT_SUPPORT=false -v /var/run/docker.sock:/var/run/docker.sock %REGISTRY%/library/install-script:%TAG% feder8 init update-vocabulary
