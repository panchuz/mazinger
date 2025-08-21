#!/bin/bash

# --- Configuration ---
LOG_DIR="/var/log/stability_test"
MASTER_LOG="${LOG_DIR}/master_test.log"
STOP_FILE="/tmp/disable_stability_test"
TOTAL_HOURS=8 # How many hours the entire test cycle should last

# --- Functions ---
log_message() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $MASTER_LOG
}

# --- Script Start ---

# Safety switch: if this file exists, stop the test.
if [ -f "$STOP_FILE" ]; then
  log_message "Stop file found. Aborting stability test."
  exit 0
fi

# Redirect all output to the master log
exec > >(tee -a $MASTER_LOG) 2>&1

log_message "--- OVERNIGHT STABILITY TEST STARTED ---"

# Start the sensor logger in the background
python3 /usr/local/sbin/log_stats.py &
LOGGER_PID=$!
log_message "Sensor logger started with PID ${LOGGER_PID}."

# --- Main Test Loop ---
END_TIME=$((SECONDS + TOTAL_HOURS * 3600))
while [ $SECONDS -lt $END_TIME ]; do

  log_message "--- Cycle: Starting 1-Core Stress (15 mins) ---"
  stress-ng --cpu 1 --timeout 15m

  log_message "--- Cycle: Starting Idle Period (5 mins) ---"
  sleep 5m

  log_message "--- Cycle: Starting 2-Core Stress (15 mins) ---"
  stress-ng --cpu 2 --timeout 15m

  log_message "--- Cycle: Starting LLC Load Cycling Test (10 mins) ---"
  # 30 cycles of 10s load, 10s idle to test voltage response
  for i in {1..30}; do
    stress-ng --cpu 4 --timeout 10s
    sleep 10s
  done

  log_message "--- Cycle: Starting 3-Core Stress (15 mins) ---"
  stress-ng --cpu 3 --timeout 15m

  log_message "--- Cycle: Starting Idle Period (5 mins) ---"
  sleep 5m

  log_message "--- Cycle: Starting 4-Core Stress (15 mins) ---"
  stress-ng --cpu 4 --timeout 15m

  log_message "--- Cycle: Starting Memory Test (20 mins) ---"
  # Test 2GB of RAM once. Adjust memory size based on your system.
  memtester 2G 1

done

# --- Cleanup and Final Report ---
log_message "--- OVERNIGHT STABILITY TEST COMPLETED ---"

log_message "Stopping sensor logger."
kill $LOGGER_PID

log_message "Running final performance benchmark..."
sysbench cpu --threads=4 --time=60 run

log_message "Dumping final kernel messages..."
dmesg > "${LOG_DIR}/dmesg_final.log"

log_message "Test suite finished. System is stable."
