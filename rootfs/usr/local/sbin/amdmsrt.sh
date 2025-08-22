#!/bin/bash

MSR_TOOL="/usr/local/sbin/amdmsrt"

# test to see if dmesg error goes away
/usr/local/sbin/amdctl -m

echo "Applying custom P-State configuration..."

# All CPU P-states are with LLC

# AMD Turbo CORE P-states
# P0 state (single thread): 4.7 GHz @ 1.3875V
# P1 state (multi thread) : 4.5 GHz @ 1.3500V
$MSR_TOOL P0=23.5@1.3875 P1=22.5@1.3500

# mid-range P-states
# P2 state: 3.6 GHz @ 1.3000V ...raised +12.5mV to prevent this:
#   [    2.134730] mce: [Hardware Error]: Machine check events logged
#   [    2.134732] mce: [Hardware Error]: CPU 0: Machine Check: 0 Bank 5: 9c00000000020e0f
#   [    2.134763] mce: [Hardware Error]: TSC 0 ADDR 13
#   [    2.134792] mce: [Hardware Error]: PROCESSOR 2:600f12 TIME 1755773029 SOCKET 0 APIC 0 microcode 0 
# P3 state: 3.3 GHz @ 1.2250V
$MSR_TOOL P2=18.0@1.3000 P3=16.5@1.2250

# Power saving P-states
# P4 state: 2.5 GHz @ 1.100mV
# P5 state: 1.7 GHz @ 1.000mV
$MSR_TOOL P4=12.5@1.1000 P5=8.5@1.000

# Northbridge
# P0 state: 2.0 GHz @ 1.1500mV with LLC
$MSR_TOOL NB_P0=10@1.1500

echo "Custom P-States applied."
