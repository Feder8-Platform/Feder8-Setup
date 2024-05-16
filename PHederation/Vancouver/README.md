# How to install the latest version of NGINX

## Prerequisites
1. Docker is installed and running.
2. The user has access to the PHederation Harbor repository containing the NGINX Docker image.

## Installation steps
1. Open a terminal window
2. Download the installation script:
      `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/PHederation/Vancouver/start-nginx.sh --output start-nginx.sh  && chmod +x start-nginx.sh`
3. Execute the script by running `./start-nginx.sh` 

# How to load CDM data into the Postgres database

## Prerequisites
1. Docker is installed and running.
2. The user has access to the PHederation Harbor repository
3. CDM data available as separate CSV files. Each CSV file has the name of the target table.

## Installation steps
1. Open a terminal window
2. Download the installation script:
   `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/PHederation/Vancouver/load-cdm-data.sh --output load-cdm-data.sh  && chmod +x load-cdm-data.sh`
3. Execute the script by running `./load-cdm-data.sh`
