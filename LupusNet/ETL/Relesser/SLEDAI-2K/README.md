# How to add SLEDAI-2K measurements after running the ETL for Relesser

## Prerequisites
1. Docker is installed and running.
2. The OMOP CDM database is running in a Docker container named `postgres`:
   * Check this by running `docker ps`. You should see the `postgres` container listed as running and healthy.
4. The ETL for RELESSER has been executed 

## Execution steps
1. Open a terminal window 
2. Download the 'add-measurements.sh' script:
   * Linux/MacOS: 
   
      `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/Relesser/SLEDAI-2K/add-measurements.sh --output add-measurements.sh  && chmod +x add-measurements.sh`
3. Execute the script by running `./add-measurements.sh` from inside the directory where the script is located.
