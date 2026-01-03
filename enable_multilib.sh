#!/bin/bash

# Color definitions
INST='\033[0;34m' # Blue for Installing
SUCC='\033[0;32m' # Green for Success
WARN='\033[1;33m' # Yellow for Reminders/Warnings
ERR='\033[0;31m'  # Red for Errors
NC='\033[0m'      # No Color

# Check if this script is executing as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${WARN} Please, run this script using sudo or as root.${NC}"
  exit 1
fi

echo -e "${INST} Enabling multilib repository...${NC}"

# Use sed to find the line [multilib] and the following line, removing the '#' comment
# This targets the specific multilib block to avoid uncommenting other sections
sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/^#//' /etc/pacman.conf

echo -e "${INST} Updating package databases...${NC}"
pacman -Syu

echo -e "${SUCC} Done! Multilib has been enabled.${NC}"

# Prompt for reboot
read -p "A reboot is recommended. Reboot now? (y/N): " confirm
if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
  reboot
else
  echo -e "${WARN} Please remember to reboot later for all changes to take effect.${NC}"
fi
