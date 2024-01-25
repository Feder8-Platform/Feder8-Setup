# How to execute the Analysis Table Generation script

## Prerequisites
1. The local installation for LupusNet is installed and running
2. The user has access to the LupusNet Harbor repository

## Execution steps
1. Open a terminal window
2. Download the 'Analysis Table Generation' run script:
   * Linux: 
     ```curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/AnalysisTable/generate-analysis-table.sh --output generate-analysis-table.sh  && chmod +x generate-analysis-table.sh```
   * Windows: 
     ```curl -L https://raw.githubusercontent.com/Feder8-Platform/Feder8-Setup/main/LupusNet/AnalysisTable/generate-analysis-table.cmd --output generate-analysis-table.cmd```
3. Execute the script (from the directory where the script is downloaded)
   * Linux: 
     ```./generate-analysis-table.sh```
   * Windows: 
     ```generate-analysis-table.cmd```
4. The script will create the analysis table and show the output of the code
