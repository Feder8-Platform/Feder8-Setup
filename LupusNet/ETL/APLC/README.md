# How to execute the ETL for APLC

## Prerequisites
1. Docker is installed and running.
2. The user has access to the LupusNet Harbor repository containing the ETL image.
3. The OMOP CDM database is running in a Docker container named `postgres`:
   * Check this by running `docker ps`. You should see the `postgres` container listed as running and healthy.
4. A tab delimited CSV file with name 'aplc.csv' containing the source data
5. Run the following command to change the default port used by nginx:
   * Windows:

     ```
     curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/APLC/custom-http-port.cmd --output custom-http-port.cmd
     ```

## Harbor login
1. Open a browser and log into Harbor @ https://harbor.lupusnet.org/c/oidc/login
2. Click on your username in the right upper corner of the screen
3. Click on 'User Profile'
4. Click on the 'copy' button to copy your CLI secret to your clipboard 
5. Open a terminal window
6. Execute the following command: `docker login harbor.lupusnet.org`
7. Login with your email address as username and the CLI secret from Harbor as password

## Execution steps
1. Open a terminal window 
2. Create a new directory for the ETL script execution, e.g.:
   * `mkdir etl_aplc`
   * `cd etl_aplc`
2. Download the ETL run script:
   * Windows:  
   
      `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/APLC/runETL.cmd --output runETL.cmd`
   * Linux/MacOS: 
   
      `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/ETL/APLC/runETL.sh --output runETL.sh  && chmod +x runETL.sh`
3. Execute the 'runETL' script by running `.\runETL.cmd` (Windows) or `./runETL.sh` (Linux/MacOS) from inside the directory where the script is located.
4. The script will request for:
    * the path to the folder that contains the input data file
    * the date when the source data was exported
5. The script will run the ETL code and show the output of the code

Please review the reports created by the script. Confirm that no patient-level information was written out before sharing them.
