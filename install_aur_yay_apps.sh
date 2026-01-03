#!/usr/bin/env bash

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

# Variables
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME="$(getent passwd "$REAL_USER" | cut -d: -f6)"
YAY_BIN="$(command -v yay)"

install_apps() {
  YAY_APPS=(
    "figma-linux-bin"
    "visual-studio-code-bin"
    "webapp-manager"
    "iriunwebcam-bin"
    "ccrypt"
    "burpsuite"
    "vesktop-bin"
    "ab-download-manager-bin"
    "localsend-bin"
  )

  OFFICIAL_REPO_APPS=(
    "obs-studio"
    "kdeconnect"
    "gparted"
    "mtools"
    "dosfstools"
    "ntfs-3g"
    "exfatprogs"
    "f2fs-tools"
    "vlc"
    "vlc-plugins-all"
    "7zip"
    "unrar"
    "zip"
    "rustup"
    "qbittorrent"
    "syncthing"
  )

  # Install Linux Headers
  echo -e "${INST} Installing Linux Headers...${NC}"
  sudo pacman -S --noconfirm --needed linux-headers

  # Yay Apps
  echo -e "${INST} Installing Yay Apps...${NC}"
  sudo -u "$REAL_USER" yay -S --noconfirm --needed --answerdiff None --answerclean None "${YAY_APPS[@]}"

  # Oficial Repository Apps
  echo -e "${INST} Installing Official Repository Apps...${NC}"
  sudo pacman -S --noconfirm --needed "${OFFICIAL_REPO_APPS[@]}"

  # Virtual Machines
  echo -e "${INST} Installing Virtual Machines...${NC}"
  sudo pacman -S --noconfirm --needed qemu-desktop virt-manager libvirt dnsmasq iptables-nft edk2-ovm

  sudo systemctl enable --now libvirtd
  sudo usermod -aG libvirt "$REAL_USER"
  sudo virsh net-autostart default
  sudo virsh net-start default

  # Install NVM
  echo -e "${INST} Installing NVM${NC}"
  sudo -u "$REAL_USER" curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | sudo -u "$REAL_USER" bash

  # Install Docker
  echo -e "${INST} Installing Docker${NC}"
  sudo pacman -S --noconfirm --needed docker docker-compose
  sudo systemctl enable --now docker.service
  sudo usermod -aG docker "$REAL_USER"
  echo -e "${SUCC} Docker installed successfully, restart to apply changes.${NC}"

  # Install Steam, Wine, Lutris for Gaming
  echo -e "${INST} Installing Steam, Wine and Lutris${NC}"
  sudo pacman -S --noconfirm --needed lutris wine-staging wine-gecko winetricks giflib lib32-giflib lib32-gnutls lib32-v4l-utils lib32-libpulse lib32-alsa-plugins lib32-libxcomposite lib32-libxinerama lib32-ncurses lib32-libxml2 lib32-freetype2 lib32-libpng lib32-sdl2 lib32-mesa vulkan-intel lib32-vulkan-intel steam
  sudo -u "$REAL_USER" yay -S --noconfirm --needed --answerdiff None --answerclean None protonup-qt

  # Reminder
  echo -e "${WARN} Remember Install your web apps: Zynga Poker, Whatsapp, Notion, Flathub, and install another apps like: Osu ${NC}"
  echo -e "${SUCC} Apps installed successfully!${NC}"
}

if pacman -Qi "yay" &>/dev/null; then
  install_apps
else
  echo -e "${WARN} Yay is not intalled.${NC}"
  echo -e "${INST} Installing Yay...${NC}"

  sudo -u "$REAL_USER" git clone https://aur.archlinux.org/yay.git /tmp/yay
  (cd /tmp/yay && sudo -u "$REAL_USER" makepkg -si --noconfirm)

  rm -rf /tmp/yay

  echo -e "${SUCC} Yay installed successfully!${NC}"

  install_apps
fi
