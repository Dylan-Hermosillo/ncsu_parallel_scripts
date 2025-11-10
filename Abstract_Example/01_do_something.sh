#!/bin/bash
# -------------------------
# 01_get_something.sh - a script to generate wrappers
# -------------------------

# --- Housekeeping ---
pwd; hostname; date
source ./config.sh

# --- Get the dataset for this job ---
JOBINDEX=$(($LSB_JOBINDEX - 1))
datasets=($(cat ${DATASET_LIST}))
DATA_PATH=${datasets[${JOBINDEX}]}

echo "Processing dataset: $DATA_PATH on `date`"
DATA_NAME=$(basename "$DATA_PATH")

: '
Potential IFS delimeter if needed (: -- modeled)
IFS=':' read -r -a data_parts <<< "$DATA_NAME"

# data_parts[0] = sample name
# data_parts[1] = other info
'

# --- Generate Wrapper ---
    # Here you would add the commands to generate the wrapper

# For example SRA Prefetch:
if [[ ! -d "$SRA_OUT_DIR/$DATA_NAME" ]]; then
    echo "Generating SRA Prefetch wrapper for $DATA_NAME"
    
    # Command to run
    COMMAND1="module load ${TOOL}"
    COMMAND2="prefetch $DATA_NAME --output-directory $SRA_OUT_DIR"
    echo "Running this: $COMMAND"

    # Write command to a wrapper file 
    echo "$COMMAND1" > $SCRIPTS_DIR/${DATA_NAME}_prefetch_wrapper.sh
    echo "$COMMAND2" >> $SCRIPTS_DIR/${DATA_NAME}_prefetch_wrapper.sh
    chmod 755 $SCRIPTS_DIR/${DATA_NAME}_prefetch_wrapper.sh

    # Append aggregate list for GNU parallel execution
    echo "$SCRIPTS_DIR/${DATA_NAME}_prefetch_wrapper.sh" >> ${SCRIPTS_DIR}/aggregate_prefetch_wrappers.txt
fi
