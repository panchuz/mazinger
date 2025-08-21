#!/bin/bash

echo "--- Power Limit Verification Test ---"
echo "This test will run for approximately 4 minutes."
echo "It will stress 1, 2, 3, and then 4 CPU cores, each for 60 seconds."

# Start the python logger in the background
python3 log_stats.py &
# Save the logger's Process ID (PID)
LOGGER_PID=$!

# Give the logger a second to start up
sleep 2

# Loop through the number of cores to stress
for i in {1..4}
do
  echo "---------------------------------------"
  echo "Stressing ${i} core(s) for 60 seconds..."
  echo "---------------------------------------"
  # Run the stress test for the current number of cores
  stress-ng --cpu ${i} --timeout 60s
  # Add a small buffer between tests
  sleep 2
done

echo "---------------------------------------"
echo "Test complete. Stopping logger."
echo "---------------------------------------"

# Stop the background logger process
kill $LOGGER_PID

echo "Done. Please upload the 'power_ramp_log.csv' file for analysis."
