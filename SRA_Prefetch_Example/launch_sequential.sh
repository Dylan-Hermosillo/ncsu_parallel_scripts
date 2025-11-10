#!/bin/bash
# -------------------------
# launcher.sh - run the wrapper generation pipeline
# Note: This is a sequential version where Job 2 waits
#       for Job 1 to complete fully
# -------------------------

# --- Housekeeping ---
    # load config
source config.sh
    # create working dir -- should already exist but just in case...
create_dir $WORKING_DIR $SCRIPTS_DIR
    # some log info
echo "Starting LSF wrapper generation at $(date)"
    # get num of jobs
export NUM_JOB=$(wc -l < "$DATASET_LIST")
# --- End Housekeeping ---

# --- Create File Structure ---
    # 01 In/Out for Wrapper Generation
create_dir $WRAP_IN $WRAP_OUT $WRAP_SCRIPTS $WRAP_OUT $WRAP_ERR
    # 02 In/Out for Prefetch
create_dir $SRA $SRA_OUT $SRA_ERR
# --- End Create File Structure ---

# --- Launch Pipeline Steps ---
# Job 1: Generate LSF Wrappers
echo "launching Job 1: LSF Wrapper Generation"
JOBID1=$(bsub -J "$JOB1[1-$NUM_JOB]%$CHUNK_SIZE" \
     -n $JOB1_CPUS \
     -q $JOB1_QUEUE \
     -R "rusage[mem=$JOB1_MEMORY]" \
     -o "${WRAP_OUT}/wrapper.gen.%J.%I.log" \
     -e "${WRAP_ERR}/wrapper.gen.%J.%I.err" \
     -W $JOB1_TIME \
     < ${SCRIPTS_DIR}/01_SRA_PREFETCH.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 1 array with id $JOBID1"

# Final Parallel Execution
echo "launching Job 2: Parallel Task Execution"
echo "Waiting for Job 1 array $JOBID1 to complete..."
bwait -w "done($JOBID1)"

    # Parameters for GNU parallel execution
CPUS=$JOB2_CPUS
AGGREGATE_FILE="${SCRIPTS_DIR}/aggregate_prefetch_wrappers.txt"
    # Run GNU parallel on the aggregated wrapper scripts
if [[ -s "$AGGREGATE_FILE" ]]; then
    echo "Running GNU Parallel on the aggregated wrapper scripts..."
    module load ${SRA_PREFETCH}
    cat ${AGGREGATE_FILE} | ${PARALLEL} -j ${CPUS} -a - \
        > "${PAR_OUT}/prefetch.task.log" \
        2> "${PAR_ERR}/prefetch.task.err"
else
    echo "Warning: Aggregate wrapper file is missing or empty. Nothing to run."
fi
echo "Completed Job 2: Parallel Task Execution"