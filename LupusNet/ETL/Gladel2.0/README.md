# How to execute the ETL for Gladel

## Prerequisites
1. Docker is installed and running.
2. The user has access to the LupusNet Harbor repository containing the ETL image.
3. The OMOP CDM database is running in a Docker container named `postgres`:
    * Check this by running `docker ps`. You should see the `postgres` container listed as running and healthy.

## Execution steps
1. Open a terminal window 
2. Create a new directory for the ETL script execution, e.g.:
   * `mkdir etl_gladel`
   * `cd etl_gladel`
2. Download the ETL run script:
    * `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Gladel2.0/runETL.sh --output runETL.sh && chmod +x runETL.sh`
3. Execute the `runETL.sh` script by running `./runETL.sh` from inside the directory where the script is located.
4. The script will request for:
    * the path to the folder that contains the input data file
    * the name of the input data file
    * the username and password to connect to the OMOP CDM database (a running Docker container named `postgres`)
5. The script will run the ETL code and show the output of the code

Please review the reports created by the script. Confirm that no patient-level information was written out before sharing them.
