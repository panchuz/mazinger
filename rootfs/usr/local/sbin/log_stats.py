#!/usr/bin/env python3
import subprocess, time, re, sys

# Accept the log file path as a command-line argument
if len(sys.argv) < 2:
    print("Usage: ./log_stats.py <output_file_path>")
    sys.exit(1)

LOG_FILE = sys.argv[1]
INTERVAL_S = 2

header = f"Timestamp,CPU_Freq_MHz,Vcore_V,CPU_Temp_C,MB_Temp_C,Package_Power_W,CPU_Fan_RPM\n"
try:
    with open(LOG_FILE, "w") as f:
        f.write(header)
except IOError as e:
    print(f"Error: Could not write to log file {LOG_FILE}. {e}")
    sys.exit(1)

try:
    while True:
        timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
        try:
            cpuinfo_out = subprocess.check_output("cat /proc/cpuinfo", shell=True, text=True)
            sensors_out = subprocess.check_output("sensors", shell=True, text=True)
        except subprocess.CalledProcessError:
            continue

        cpu_freq = re.search(r"cpu MHz\s+:\s+([\d\.]+)", cpuinfo_out).group(1) if re.search(r"cpu MHz\s+:\s+([\d\.]+)", cpuinfo_out) else "N/A"
        vcore = re.search(r"Vcore Voltage:\s+([\d\.]+)", sensors_out).group(1) if re.search(r"Vcore Voltage:\s+([\d\.]+)", sensors_out) else "N/A"
        cpu_temp = re.search(r"CPU Temperature:\s+\+([\d\.]+)", sensors_out).group(1) if re.search(r"CPU Temperature:\s+\+([\d\.]+)", sensors_out) else "N/A"
        mb_temp = re.search(r"MB Temperature:\s+\+([\d\.]+)", sensors_out).group(1) if re.search(r"MB Temperature:\s+\+([\d\.]+)", sensors_out) else "N/A"
        pkg_power = re.search(r"power1:\s+([\d\.]+)", sensors_out).group(1) if re.search(r"power1:\s+([\d\.]+)", sensors_out) else "N/A"
        cpu_fan = re.search(r"CPU Fan Speed:\s+([\d]+)", sensors_out).group(1) if re.search(r"CPU Fan Speed:\s+([\d]+)", sensors_out) else "N/A"

        log_line = f"{timestamp},{cpu_freq},{vcore},{cpu_temp},{mb_temp},{pkg_power},{cpu_fan}\n"
        
        with open(LOG_FILE, "a") as f:
            f.write(log_line)

        time.sleep(INTERVAL_S)
except KeyboardInterrupt:
    sys.exit(0)
