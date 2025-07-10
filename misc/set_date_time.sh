#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

echo "Enter the desired date and time (e.g., YYYY-MM-DD HH:MM:SS):"
read user_datetime

# Validate input (optional but recommended)
# You can add more robust validation here to ensure the input format is correct.
if ! date -d "$user_datetime" &>/dev/null; then
    echo "Invalid date/time format. Please use YYYY-MM-DD HH:MM:SS"
    exit 1
fi

# Set the system date and time
sudo date --set="$user_datetime"

echo "System date and time updated to: $(date)"
