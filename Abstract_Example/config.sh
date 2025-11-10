#!/bin/bash

# -------------------------
# config.sh - pipeline configuration
# -------------------------

# PART 1 -- LSF Wrapper Generation

# 00 Set Working Directory
export WORKING_DIR="/path/to/working/dir"

# 01 Input/Output directories; for the wrapper generation
export WRAP_IN="$WORKING_DIR/01_wrapper_generation/input"
export WRAP_OUT="$WORKING_DIR/01_wrapper_generation/output"
export WRAP_LOGS_DIR="$WRAP_OUT/logs"
export WRAP_OUT="$WRAP_LOGS_DIR/our"
export WRAP_ERR="$WRAP_LOGS_DIR/err"
export SCRIPTS_DIR="$WORKING_DIR/01_wrapper_generation/scripts"

# 02 Data
export DATASET_LIST="$WORKING_DIR/dataset_list.txt"

# 03 Mod configurations
export JOB1_CPUS=6
export JOB1_QUEUE="shared_memory"
export JOB1_MEMORY="4GB"
export JOB1_TIME="1:00"

# 04 Job Parameters
export JOB1="get_something_01A"
export CHUNK_SIZE=50 # number of jobs to run concurrently in lsf

# Job 2 -- Parallel Task Execution (Placeholder if second congif parameters are needed)

# 00 Parallel Tool & Tool to run
export PARALLEL="/path/to/gnu/parallel"
export TOOL="/path/to/tool/to/run"

# 01 Input/Output directories; for the parallel execution
export PAR_IN="/path/to/parallel/input"
export PAR_OUT="/path/to/parallel/output"
export PAR_LOGS="$PAR_OUT/logs"
export PAR_OUT="$PAR_LOGS/out"
export PAR_ERR="$PAR_LOGS/err"

export PAR_SCRIPTS_DIR="/path/to/parallel/scripts"

#02  Data
export PAR_DATASET_LIST=

#03 Mod configurations
export JOB2_CPUS=6
export JOB2_QUEUE="shared_memory"
export JOB2_MEMORY="4GB"
export JOB2_TIME="1:00"

#04 Job Parameters
export JOB2="process_something_02A"

# PART 3 -- For SRA Prefetch Example
export SRA_OUT_DIR="/path/to/sra/output"

# Some custom functions for our scripts
#
# --------------------------------------------------
function init_dir {
    for dir in $*; do
        if [ -d "$dir" ]; then
            rm -rf $dir/*
        else
            mkdir -p "$dir"
        fi
    done
}

# --------------------------------------------------
function create_dir {
    for dir in $*; do
        if [[ ! -d "$dir" ]]; then
          echo "$dir does not exist. Directory created"
          mkdir -p $dir
        fi
    done
}

# --------------------------------------------------
function lc() {
    wc -l $1 | cut -d ' ' -f 1
}