#!/bin/bash

# dCloud VPN Connection Script
# This script establishes a VPN connection to dCloud using OpenConnect
# and automatically reconnects if the connection drops.

# Required environment variables (set these in your ~/.bash_profile or ~/.bashrc):
# - VPN_SERVER: The dCloud VPN server address
# - VPN_USERNAME: Your dCloud username
# - VPN_PASSWORD: Your dCloud password

: "${VPN_SERVER:?Variable unset or empty - please set VPN_SERVER in your environment}"
: "${VPN_USERNAME:?Variable unset or empty - please set VPN_USERNAME in your environment}"
: "${VPN_PASSWORD:?Variable unset or empty - please set VPN_PASSWORD in your environment}"

# Create log directory if it doesn't exist
LOG_DIR="/var/log/openconnect"
LOG_FILE="$LOG_DIR/openconnect.log"

if [ ! -d "$LOG_DIR" ]; then
  echo "Creating log directory: $LOG_DIR"
  sudo mkdir -p "$LOG_DIR"
  sudo chmod 755 "$LOG_DIR"
fi

echo "Starting dCloud VPN connection to $VPN_SERVER as $VPN_USERNAME"
echo "Log file: $LOG_FILE"
echo "Press Ctrl+C to stop the VPN connection"
echo ""

run() {
  echo "$VPN_PASSWORD" | sudo openconnect "$VPN_SERVER" \
    --passwd-on-stdin \
    -u "$VPN_USERNAME" \
    --no-dtls \
    --allow-insecure-crypto \
    --verbose \
    --timestamp \
    >>"$LOG_FILE" 2>&1
}

until (run); do
  EXIT_CODE=$?
  echo "openconnect crashed with exit code $EXIT_CODE - respawning..." >&2
  sleep 1
done

