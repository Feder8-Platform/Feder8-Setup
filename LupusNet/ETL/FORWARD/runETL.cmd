@echo off

set "data_folder=%CD%/data"
set /p "data_folder=Input Data folder [%data_folder%]: "

set "reports_folder=%CD%/reports"

set "db_username=feder8_admin"
set /p "db_username=DB username [%db_username%]: "

set "db_password="
set /p "db_password=DB password: "

SET REGISTRY=harbor.lupusnet.org
SET REPOSITORY=etl-forward
SET IMAGE=etl
SET TAG=latest

docker pull %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%

docker run --rm --network feder8-net --env DB_USER=%db_username% --env DB_PASSWORD=%db_password% -v %data_folder%:/script/etl/data -v %reports_folder%:/script/etl/forward/reports %REGISTRY%/%REPOSITORY%/%IMAGE%:%TAG%
