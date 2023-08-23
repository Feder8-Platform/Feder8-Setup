@ECHO off

SET TAG=latest

docker pull harbor.lupusnet.org/distributed-analytics/data-profiler:%TAG%

docker run --rm --name data-profiler -v shared:/var/lib/shared -v %CD%/data-profiler-results:/script/data_profiler_results --env THERAPEUTIC_AREA=lupus --env CDM_VERSION=5.4 --env INDICATION=lupus --env SCRIPT_UUID=82f80336-c3b7-4d09-b325-db8d2965fb86 --env LOG_LEVEL=DEBUG --network feder8-net harbor.lupusnet.org/distributed-analytics/data-profiler:%TAG%
