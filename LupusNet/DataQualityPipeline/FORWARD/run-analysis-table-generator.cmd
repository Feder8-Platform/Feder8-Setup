@ECHO off

SET TAG=latest

docker pull harbor.lupusnet.org/distributed-analytics/analysis-table-generator-lupus-forward:%TAG%

docker run --rm --name analysis-table-generator -v shared:/var/lib/shared --env THERAPEUTIC_AREA=lupus --env CDM_VERSION=5.4 --env INDICATION=lupus --env SCRIPT_UUID=82f80336-c3b7-4d09-b325-db8d2965fb86 --env LOG_LEVEL=DEBUG --network harbor.lupusnet.org/distributed-analytics/analysis-table-generator-lupus-forward:%TAG%
