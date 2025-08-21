#!/usr/bin/env python3
import subprocess
import time
import re

# --- Configuration ---
LOG_FILE = "throttling_log_final.csv"
INTERVAL_S = 1 # Time between measurements in seconds

# --- Main Script ---
print(f"Starting data logger. Writing to {LOG_FILE}")
print("Press Ctrl+C to stop.")

# Write the header to the log file
header = f"Row_ID (interval={INTERVAL_S}s),CPU_Freq_MHz,Vcore_V,CPU_Temp_C,MB_Temp_C,Package_Power_W,CPU_Fan_RPM"
with open(LOG_FILE, "w") as f:
    f.write(header + "\n")

row_id = 0
try:
    while True:
        row_id += 1
        
        # Run commands to get system stats
        try:
            # *** THIS IS THE CORRECTED SECTION ***
            cpuinfo_out = subprocess.check_output("cat /proc/cpuinfo", shell=True, text=True)
            sensors_out = subprocess.check_output("sensors", shell=True, text=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running command: {e}")
            time.sleep(INTERVAL_S)
            continue

        # --- Use regular expressions to find values reliably ---
        # Frequency from /proc/cpuinfo (more reliable)
        cpu_freq_match = re.search(r"cpu MHz\s+:\s+([\d\.]+)", cpuinfo_out)
        cpu_freq = cpu_freq_match.group(1) if cpu_freq_match else "N/A"

        # Values from the reliable ATK0110 interface
        vcore_match = re.search(r"Vcore Voltage:\s+([\d\.]+)", sensors_out)
        vcore = vcore_match.group(1) if vcore_match else "N/A"

        cpu_temp_match = re.search(r"CPU Temperature:\s+\+([\d\.]+)", sensors_out)
        cpu_temp = cpu_temp_match.group(1) if cpu_temp_match else "N/A"

        mb_temp_match = re.search(r"MB Temperature:\s+\+([\d\.]+)", sensors_out)
        mb_temp = mb_temp_match.group(1) if mb_temp_match else "N/A"
        
        cpu_fan_match = re.search(r"CPU Fan Speed:\s+([\d]+)", sensors_out)
        cpu_fan = cpu_fan_match.group(1) if cpu_fan_match else "N/A"

        # Power from fam15h_power
        power_match = re.search(r"power1:\s+([\d\.]+)", sensors_out)
        pkg_power = power_match.group(1) if power_match else "N/A"

        # Assemble the CSV line
        log_line = f"{row_id},{cpu_freq},{vcore},{cpu_temp},{mb_temp},{pkg_power},{cpu_fan}"
        
        print(log_line)
        with open(LOG_FILE, "a") as f:
            f.write(log_line + "\n")

        time.sleep(INTERVAL_S)

except KeyboardInterrupt:
    print(f"\nLogging stopped. Your data is in {LOG_FILE}")