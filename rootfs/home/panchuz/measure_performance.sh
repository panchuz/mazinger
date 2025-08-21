#!/bin/bash

# Define the duration of the test in seconds.
# 300 seconds (5 minutes) is long enough to trigger any power-limit throttling.
TEST_DURATION=300

echo "--- Starting CPU Performance Throughput Test ---"
echo "This will run a 4-thread CPU benchmark for ${TEST_DURATION} seconds."
echo "A higher final score is better."
echo "Running, please wait..."

# Run the sysbench test and capture its output.
# The test calculates prime numbers as fast as possible.
OUTPUT=$(sysbench cpu --threads=4 --time=${TEST_DURATION} run)

# Extract the "total number of events" which serves as our performance score.
SCORE=$(echo "$OUTPUT" | grep 'total number of events:' | awk '{print $5}')

echo "------------------------------------------------"
echo "Test Complete."
echo "Performance Score (Total Events): ${SCORE}"
echo "------------------------------------------------"