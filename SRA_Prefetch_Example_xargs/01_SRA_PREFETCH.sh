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
# For example SRA Prefetch using Apptainer
if [[ ! -f "$SRA/$DATA_NAME/${DATA_NAME}.sra" ]]; then
    echo "Generating SRA Prefetch wrapper for $DATA_NAME"

    # Wrapper script content
    COMMAND1="mkdir -p ${SRA}/${DATA_NAME}"
    COMMAND2="${APPT} exec --bind ${SRA}:${SRA} ${SRA_TOOLKIT} prefetch ${DATA_NAME} -O ${SRA} > ${SRA_OUT}/${DATA_NAME}_prefetch.log 2> ${SRA_ERR}/${DATA_N>
    # Write wrapper file
    echo "$COMMAND1" > "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"
    echo "$COMMAND2" >> "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"
    chmod 755 "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh"

    # Append to aggregate for GNU Parallel
    echo "${WRAP_SCRIPTS}/${DATA_NAME}_prefetch_wrapper.sh" >> "${SCRIPTS_DIR}/aggregate_prefetch_wrappers.txt"
fi
