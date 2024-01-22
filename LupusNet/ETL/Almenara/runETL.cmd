@echo off

set "data_folder=%CD%/data"
set /p "data_folder=Input Data folder [%data_folder%]: "

set "reports_folder=%CD%/reports"

set "db_username=feder8_admin"
set /p "db_username=DB username [%db_username%]: "

set "db_password="
set /p "db_password=DB password: "

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=etl-almenara
SET IMAGE=etl
SET TAG=latest

echo "Login into Harbor (please enter your email address and Harbor CLI secret if needed)"
docker login %REGISTRY%

docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --network feder8-net --env DB_USER=%db_username% --env DB_PASSWORD=%db_password% -v %data_folder%:/script/etl/data -v %reports_folder%:/script/etl/almenara/reports %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

echo "Set permissions on new DB schema's"
docker exec -it postgres psql -U postgres -d OHDSI -c "REASSIGN OWNED BY feder8_admin TO ohdsi_admin;REASSIGN OWNED BY ohdsi_app_user TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_almenara_final TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_almenara_final TO ohdsi_app;GRANT USAGE ON SCHEMA lupus_almenara_src TO ohdsi_app;GRANT SELECT ON ALL TABLES IN SCHEMA lupus_almenara_src TO ohdsi_app;"

echo "End of script"
echo "Please inspect and share the output under the following folder: "
echo "%reports_folder%"
