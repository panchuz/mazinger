#!/bin/bash

MSR_TOOL="/usr/local/sbin/amdmsrt"

# only for dmesg error to go away
/usr/local/sbin/amdctl -m > null |echo "userspace MSR writing enabled ;)"

echo "Applying custom P-State configuration..."

# All CPU P-states are with LLC = [Enable]
# CPU/NB P-state are with LLC = [Auto]

# AMD Turbo CORE P-states
# P0 state (single thread): 4.6 GHz @ 1.3875V
# P1 state (multi thread) : 4.5 GHz @ 1.3500V
#$MSR_TOOL P0=23@1.3875 P1=22.5@1.3500 (previous, P0 undervolted)
$MSR_TOOL P0=23@1.3750 P1=22.5@1.3500

# mid-range P-states
# P2 state: 3.6 GHz @ 1.3000V
# P3 state: 3.3 GHz @ 1.2250V
$MSR_TOOL P2=18.0@1.3000 P3=16.5@1.2250

# Power saving P-states
# P4 state: 2.5 GHz @ 1.100mV
# P5 state: 1.7 GHz @ 1.000mV
$MSR_TOOL P4=12.5@1.1000 P5=8.5@1.000

# Northbridge: the CPU/NB voltage setting (below) does NOT work.
# it does not change real voltage, it only changes the indicated value.
# CPU/NB frequency setting DOES work, but changing it in BIOS
# setup seems better, so as to be sure it is aligned with CPU/NB
# voltage and HT frequency (recomended to be same value).
# In any case, rising CPU/NB voltage ALWAYS resulted in TSC WARP error...
# So these are the optimized values found (2025-09):
# Only here for the output of AMDmsrTweak to be correct
# (it does not have any real effect)
# P0 state: 2.0 GHz @ 1.0625mV
$MSR_TOOL NB_P0=10@1.0625


echo "Custom P-States succesfully applied"
$MSR_TOOL |grep " at "
