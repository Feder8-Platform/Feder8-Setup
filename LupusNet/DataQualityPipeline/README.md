# How to execute the Data Quality Pipeline

## Prerequisites
1. The local installation for LupusNet is installed and running
2. The user has access to the LupusNet Harbor repository

## Execution steps
1. Open a terminal window
2. Download the 'Data Quality Pipeline' run script:
   * Linux: `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/DataQualityPipeline/run-data-quality-pipeline.sh --output run-data-quality-pipeline.sh  && chmod +x run-data-quality-pipeline.sh`
   * Windows: `curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/DataQualityPipeline/run-data-quality-pipeline.cmd --output run-data-quality-pipeline.cmd`
3. Execute the script (from the directory where the script is downloaded)
   * Linux: `./run-data-quality-pipeline.sh` 
   * Windows: `run-data-quality-pipeline.cmd`
4. The script will run the Data Quality Pipeline and show the output of the code
5. The result files will be available in a subfolder 'qa'

Please review the logs and result files created by the script before sharing. 
