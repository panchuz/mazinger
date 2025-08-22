#!/bin/bash

# --- Configuration ---
# Generate a unique timestamp for this test run
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG_DIR="/var/log/stability_test"
MASTER_LOG="${LOG_DIR}/master_${TIMESTAMP}.log"
SENSOR_LOG="${LOG_DIR}/sensor_${TIMESTAMP}.csv"
DMESG_LOG="${LOG_DIR}/dmesg_${TIMESTAMP}.log"
STOP_FILE="/tmp/disable_stability_test"
TOTAL_HOURS=8

# --- Functions ---
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# --- Script Start ---
# Safety switch
if [ -f "$STOP_FILE" ]; then
  log_message "Stop file found. Aborting stability test."
  exit 0
fi

# Redirect all script output to the unique master log file
exec > >(tee -a $MASTER_LOG) 2>&1

log_message "--- OVERNIGHT STABILITY TEST STARTED ---"
log_message "Log files for this run will use timestamp: ${TIMESTAMP}"

# Start the sensor logger with the unique filename
python3 /usr/local/sbin/log_stats.py "$SENSOR_LOG" &
LOGGER_PID=$!
log_message "Sensor logger started with PID ${LOGGER_PID}."

# Dump initial kernel log
dmesg > "${LOG_DIR}/dmesg_initial_${TIMESTAMP}.log"

# --- Main Test Loop ---
END_TIME=$((SECONDS + TOTAL_HOURS * 3600))
CYCLE_COUNT=1
while [ $SECONDS -lt $END_TIME ]; do
  log_message "--- Starting Cycle #${CYCLE_COUNT} ---"
  
  log_message "Phase: 1-Core Stress (15 mins)"
  stress-ng --cpu 1 --timeout 15m

  log_message "Phase: Idle Period (5 mins)"
  sleep 5m

  log_message "Phase: 4-Core Stress (15 mins)"
  stress-ng --cpu 4 --timeout 15m
  
  log_message "Phase: LLC Load Cycling Test (10 mins)"
  for i in {1..30}; do
    stress-ng --cpu 4 --timeout 10s
    sleep 10s
  done
  
  log_message "Phase: Memory Test (20 mins)"
  # FIX: Redirect stdout to /dev/null to hide progress bar characters
  # stderr is still captured in the main log for real errors.
  memtester 2G 1 > /dev/null

  log_message "Phase: Dumping periodic kernel log..."
  dmesg > "${LOG_DIR}/dmesg_cycle${CYCLE_COUNT}_${TIMESTAMP}.log"
  
  log_message "--- Finished Cycle #${CYCLE_COUNT} ---"
  ((CYCLE_COUNT++))
done

# --- Cleanup and Final Report ---
log_message "--- OVERNIGHT STABILITY TEST COMPLETED ---"
log_message "Stopping sensor logger."
kill $LOGGER_PID

log_message "Running final performance benchmark..."
sysbench cpu --threads=4 --time=60 run

log_message "Test suite finished successfully."
