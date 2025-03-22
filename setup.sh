#!/bin/bash

# Make the main script executable
chmod +x server_monitor.sh

# Check if sshpass is installed
if ! command -v sshpass &> /dev/null; then
    echo "sshpass is required for this application."
    echo "On Windows with WSL, you can install it with: sudo apt-get install sshpass"
    echo "On Linux, you can install it with: sudo apt-get install sshpass (Debian/Ubuntu) or sudo yum install sshpass (CentOS/RHEL)"
fi

# Check if bc is installed
if ! command -v bc &> /dev/null; then
    echo "bc is required for this application."
    echo "On Windows with WSL, you can install it with: sudo apt-get install bc"
    echo "On Linux, you can install it with: sudo apt-get install bc (Debian/Ubuntu) or sudo yum install bc (CentOS/RHEL)"
fi

echo "Setup complete. Run ./server_monitor.sh to start the application."
