[Unit]
Description=Set Custom CPU P-States for FX-4100
# Start after the system has finished booting major userspace components
After=sysinit.target local-fs.target
# Ensure critical hardware services are ready
After=systemd-modules-load.service
Before=graphical.target multi-user.target

[Service]
Type=oneshot
# The path to our script
ExecStart=/usr/local/sbin/amdmsrt.sh
# Remain after exit so the script doesn't get killed
RemainAfterExit=no
# Run with root privileges
User=root
# Send output to journal for debugging
StandardOutput=journal

[Install]
# Start this service when multi-user mode is reached
WantedBy=multi-user.target
