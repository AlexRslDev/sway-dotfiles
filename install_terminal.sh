#!/usr/bin/env bash

# Color definitions
INST='\033[0;34m' # Blue for Installing
SUCC='\033[0;32m' # Green for Success
WARN='\033[1;33m' # Yellow for Reminders/Warnings
ERR='\033[0;31m'  # Red for Errors
NC='\033[0m'      # No Color

# CHECK IF THIS SCRIPT IS EXECUTING AS ROOT
if [ "$EUID" -ne 0 ]; then
  echo -e "${WARN} Please, run this script using sudo or as root.${NC}"
  exit 1
fi

# VARIABLES
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
LOCAL_ZSH_PLUGINS="$REAL_HOME/.oh-my-zsh/custom/plugins"

# TERMINAL CONFIG
echo -e "${INST} Installing Zsh Config...${NC}"
sudo pacman -S --noconfirm --needed zsh
chsh -s /usr/bin/zsh "$REAL_USER"
mkdir -p "$LOCAL_ZSH_PLUGINS"

if
  [ ! -d "$REAL_HOME/.oh-my-zsh" ]
then
  sudo -u "$REAL_USER" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

sudo -u "$REAL_USER" cp -rv ./.oh-my-zsh/custom/plugins/* "$LOCAL_ZSH_PLUGINS/"
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

cp .zshrc ~/

echo -e "${SUCC} Zsh Config Installed Successfully!${NC}"
