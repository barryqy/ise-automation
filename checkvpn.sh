#!/bin/bash

# VPN Health Check and Auto-Restart Script
# This script checks if VPN is running and restarts it if needed
# Can be run manually or added to scripts that need VPN connectivity

VPN_CHECK_HOST="198.18.133.27"
VPN_CHECK_PORT="443"
VPN_CHECK_TIMEOUT=3

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

check_vpn_process() {
  # Check if openconnect process is running (not zombie)
  if ps aux | grep -v grep | grep openconnect | grep -v '\[' > /dev/null 2>&1; then
    return 0  # VPN process exists
  else
    return 1  # VPN process not found or zombie
  fi
}

check_vpn_connectivity() {
  # Test connectivity to ISE
  if timeout ${VPN_CHECK_TIMEOUT} bash -c "echo > /dev/tcp/${VPN_CHECK_HOST}/${VPN_CHECK_PORT}" 2>/dev/null; then
    return 0  # Connection successful
  else
    return 1  # Connection failed
  fi
}

kill_zombie_vpn() {
  echo -e "${YELLOW}Killing zombie VPN processes...${NC}"
  pkill -9 -f startvpn 2>/dev/null
  pkill -9 -f openconnect 2>/dev/null
  sleep 2
}

restart_vpn() {
  echo -e "${YELLOW}Restarting VPN connection...${NC}"
  cd /home/developer/src/ise-automation
  
  # Source environment variables
  if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
  fi
  
  # Check if required variables are set
  if [ -z "$VPN_SERVER" ] || [ -z "$VPN_USERNAME" ] || [ -z "$VPN_PASSWORD" ]; then
    echo -e "${RED}ERROR: VPN environment variables not set!${NC}"
    echo "Please run: source ~/.bash_profile"
    return 1
  fi
  
  # Start VPN in background
  ./startvpn.sh &
  
  # Wait for VPN to establish
  echo -e "${YELLOW}Waiting for VPN to connect...${NC}"
  for i in {1..15}; do
    sleep 2
    if check_vpn_connectivity; then
      echo -e "${GREEN}✓ VPN connected successfully!${NC}"
      return 0
    fi
    echo -n "."
  done
  
  echo -e "\n${RED}✗ VPN failed to connect after 30 seconds${NC}"
  return 1
}

main() {
  echo "=== VPN Health Check ==="
  
  # Check if VPN process is running
  if check_vpn_process; then
    echo -e "${GREEN}✓ VPN process is running${NC}"
    
    # Check if we can actually reach ISE
    if check_vpn_connectivity; then
      echo -e "${GREEN}✓ ISE is reachable (${VPN_CHECK_HOST}:${VPN_CHECK_PORT})${NC}"
      echo -e "${GREEN}✓ VPN is healthy!${NC}"
      exit 0
    else
      echo -e "${RED}✗ ISE is NOT reachable (VPN process exists but no connectivity)${NC}"
      kill_zombie_vpn
      restart_vpn
      exit $?
    fi
  else
    echo -e "${RED}✗ VPN process is not running or is zombie${NC}"
    kill_zombie_vpn
    restart_vpn
    exit $?
  fi
}

# Run main function
main
