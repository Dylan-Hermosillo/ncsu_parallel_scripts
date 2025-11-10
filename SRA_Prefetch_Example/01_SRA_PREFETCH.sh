#!/bin/bash
# -------------------------
# 01_SRA_PREFETCH.sh - a script to generate wrappers to prefetch SRA datasets and run them in parallel
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

# --- Generate Wrapper ---

# For example SRA Prefetch:
if [[ ! -f "$SRA/$DATA_NAME/${DATA_NAME}.sra" ]]; then
    echo "Generating SRA Prefetch wrapper for $DATA_NAME"
    
    # Command to run
    COMMAND="bash -l -c \"module load ${PREFETCH}; prefetch ${DATA_NAME} --output-directory ${SRA}/${DATA_NAME} > ${SRA_OUT}/${DATA_NAME}_prefetch.log 2> ${SRA_ERR}/${DATA_NAME}_prefetch.err\""
    echo "Running this: $COMMAND"

    # Write command to a wrapper file 
    echo "$COMMAND" > ${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh
    chmod 755 ${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh

    # Append aggregate list for GNU parallel execution
    echo "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh" >> ${SCRIPTS_DIR}/aggregate_prefetch_wrappers.txt
fi
