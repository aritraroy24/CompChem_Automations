# Gaussian Job Automation (automation.sh)

This code automates running Gaussian calculations by monitoring a folder for new .gjf input files, executing the jobs, organizing the output, and launching follow-up single point energy jobs.

## Features

- Monitors a folder for new .gjf input files and automatically runs Gaussian calculations when detected
- Runs geometry optimizations and frequency calculations
- Extracts key output data (energies, geometries, etc.) and saves to organized output folders
- Identifies and handles failures due to common Gaussian errors 
- Automatically generates and runs single point energy jobs using the final structures
- Loops continuously to keep executing new jobs as input files are added

## Usage

To use this automation:

1. Save Gaussian input files (.gjf) to the root folder that the code monitors
2. The script will automatically detect new jobs and run them
3. Optimized geometries, energies, frequencies, etc. will be extracted and saved 
4. Follow-up single point energy calculations will be automatically generated and executed
5. Outputs are organized into `success` and `error` folders for each job

The key output files generated are:

- `filename.log` - Gaussian output log file
- `filename.chk` - Checkpoint file for restarting
- `filename_result.txt` - Key extracted data including energies 
- `filename_coordinates.txt` - Optimized geometry coordinates

## Code Overview

- `runCalculation()`: Main job execution function  
    - Runs Gaussian, monitors for completion & errors
    - Extracts key output data and geometries
    - Organizes output files into folders
- `filenameStorage()`: Automatically generates single point energy jobs
- Main loop:
    - Continuously monitors for new input files
    - Runs jobs via `runCalculation()`
    - Passes data to `filenameStorage()` to create follow-up calculations

The code handles various errors and extraction of data/geometries when possible even for failed jobs.

Overall, this provides a convenient automation pipeline for Gaussian, requiring only input files to be provided and organized outputs are generated.
