# How to execute the feasibility script for Research Question 2 (RQ2)

## Prerequisites
1. The local installation for LupusNet is installed and running
2. The user has access to the LupusNet Harbor repository

## Execution steps
1. Open a terminal window
2. Download the 'RQ2 feasibility' run script:
    * Linux:
      ```curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/RQ2-feasibility/run-rq2-feasibility.sh --output run-rq2-feasibility.sh  && chmod +x run-rq2-feasibility.sh```
    * Windows:
      ```curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/RQ2-feasibility/run-rq2-feasibility.cmd --output run-rq2-feasibility.cmd```
3. Execute the script (from the directory where the script is downloaded)
    * Linux:
      ```./run-rq2-feasibility.sh```
    * Windows:
      ```run-rq2-feasibility.cmd```
4. The script will run the RQ2 feasibility and show the output of the code
5. The result file will be available in a subfolder 'results'

Please review the log and result file created by the script before sharing. 
