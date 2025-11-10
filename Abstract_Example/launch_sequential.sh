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
create_dir $WORKING_DIR
    # some log info
echo "Starting LSF wrapper generation at $(date)"
  # get num of jobs
export NUM_JOB=$(wc -l < "$DATASET_LIST")
# --- End Housekeeping ---

# --- Create File Structure ---
    # 01 In/Out for Wrapper Generation
create_dir $WRAP_IN $WRAP_OUT $LOGS_DIR $SCRIPTS_DIR $WRAP_OUT $WRAP_ERR
    # 02 In/Out for Parallel Execution
create_dir $PAR_IN $PAR_OUT $PAR_LOGS_DIR $PAR_SCRIPTS_DIR $PAR_OUT $PAR_ERR
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
     < ${SCRIPTS_DIR}/01_do_something.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 1 array with id $JOBID1"

# Job 2: OPTIONAL
: ' Potential for a second job  that is dependent on the first job
echo "Launching Job 2: [Task Description Here]"
JOBID2=$(bsub -J "$JOB2[1-$NUM_JOB]%$CHUNK_SIZE" \
     -n $JOB2_CPUS \
     -q $JOB2_QUEUE \
     -R "rusage[mem=$JOB2_MEMORY]" \
     -o "${PAR_OUT}/parallel.task.%J.%I.log" \
     -e "${PAR_ERR}/parallel.task.%J.%I.err" \
     -w "done($JOBID1)" \
     -W $JOB2_TIME \
     < ${PAR_SCRIPTS_DIR}/02_parallel_something.sh | awk '{print $2}' | tr -d '<>[]')
echo "Submitted Job 2 array with id $JOBID2"
# --- End Launch Pipeline Steps ---
'

# Final Parallel Execution
echo "launching Job 2: Parallel Task Execution"
echo "Waiting for Job 1 array $JOBID1 to complete..."
bwait -w "done($JOBID1)"

    # Parameters for GNU parallel execution
CPUS=$JOB2_CPUS
PARALLEL=${PARALLEL}
AGGREGATE_FILE="${SCRIPTS_DIR}/aggregate_parallel_wrappers.txt"
    # Run GNU parallel on the aggregated wrapper scripts
if [[ -s "$AGGREGATE_FILE" ]]; then
    echo "Running GNU Parallel on the aggregated wrapper scripts..."
    $PARALLEL -j "$CPUS" < "$AGGREGATE_FILE" \
        > "${PAR_OUT}/parallel.task.log" \
        2> "${PAR_ERR}/parallel.task.err"
else
    echo "Warning: Aggregate wrapper file is missing or empty. Nothing to run."
fi
echo "Completed Job 2: Parallel Task Execution"