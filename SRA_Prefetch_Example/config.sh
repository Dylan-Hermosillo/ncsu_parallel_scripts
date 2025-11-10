#!/bin/bash

# -------------------------
# config.sh - pipeline configuration
# -------------------------

# PART 1 -- LSF Wrapper Generation

# 00 Set Working Directory
export WORKING_DIR="/share/ivirus/dhermos/GNU_TEST"
export SCRIPTS_DIR="$WORKING_DIR/scripts" # houses main scripts - launcher, 01, 02, aggregate, etc.

# 01 Input/Output directories; for the wrapper generation
export WRAP_OUT="$WORKING_DIR/01_wrapper_generation"
export WRAP_SCRIPTS="$WORKING_DIR/01_wrapper_generation/scripts" # wrapper scripts to be aggregated
export WRAP_OUTLOG="$WRAP_OUT/out"
export WRAP_ERRLOG="$WRAP_OUT/err"

# 02 Data
export DATASET_LIST="$WORKING_DIR/test_data.txt"

# 03 Mod configurations
export JOB1_CPUS=6
export JOB1_QUEUE="shared_memory"
export JOB1_MEMORY="4GB"
export JOB1_TIME="1:00"

# 04 Job Parameters
export JOB1="get_sra prefetch_01A"
export CHUNK_SIZE=50

# PART 2 -- GNU Parallel Execution
# 00 Parallel Tool
export PARALLEL="/rs1/shares/brc/admin/tools/parallel-20250922/bin/parallel"
# 01 Input/Output directories; for the parallel execution
export PAR_DIR="$WORKING_DIR/02_parallel_execution"
export PAR_OUT="$PAR_DIR/out"
export PAR_ERR="$PAR_DIR/err"

# PART 3 -- SRA Prefetch Task Execution


# 01 Input/Output directories; for the prefetch
export SRA="$WORKING_DIR/02_SRA_prefetch"
export SRA_OUT="$SRA/out"
export SRA_ERR="$SRA/err"

: '
#02  Data
#export SRA_DATASET_LIST= not needed

#03 Mod configurations
export JOB2_CPUS=6
export JOB2_QUEUE="shared_memory"
export JOB2_MEMORY="4GB"
export JOB2_TIME="1:00"

#04 Job Parameters
export JOB2="process_something_02A"
'

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