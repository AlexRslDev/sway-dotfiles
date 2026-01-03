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

# Apps List
APPS=(
  "com.bitwarden.desktop"
  "com.github.PintaProject.Pinta"
  "com.github.flxzt.rnote"
  "com.github.huluti.Curtail"
  "com.github.tenderowl.frog"
  "com.github.unrud.VideoDownloader"
  "com.jeffser.Pigment"
  "com.protonvpn.www"
  "com.rafaelmardojai.Blanket"
  "com.rafaelmardojai.SharePreview"
  "com.spotify.Client"
  "com.warlordsoftwares.formatlab"
  "io.github.alainm23.planify"
  "io.github.bytezz.IPLookup"
  "io.github.shundhammer.qdirstat"
  "io.github.wartybix.Constrict"
  "io.github.zefr0x.hashes"
  "io.gitlab.adhami3310.Converter"
  "it.mijorus.gearlever"
  "me.iepure.devtoolbox"
  "org.feichtmeier.Musicpod"
  "org.gnome.Loupe"
  "org.gnome.Mines"
  "org.gnome.Papers"
  "org.gnome.TextEditor"
  "org.inkscape.Inkscape"
  "org.kde.kalk"
  "org.kde.kdenlive"
  "org.kde.kruler"
  "org.onlyoffice.desktopeditors"
  "org.sqlitebrowser.sqlitebrowser"
  "org.telegram.desktop"
  "org.tenacityaudio.Tenacity"
  "org.upscayl.Upscayl"
  "rest.insomnia.Insomnia"
  "org.gnome.baobab"
)

if pacman -Qi "flatpak" &>/dev/null; then
  echo -e "${INST} Installing Flathub Apps...${NC}"

  sudo -u "$REAL_USER" flatpak install flathub -y "${APPS[@]}"

  echo -e "${SUCC} Flathub Apps installed successfully!${NC}"
else
  echo -e "${WARN} Flatpak is not intalled.${NC}"
  echo -e "${INST} Installing Flatpak...${NC}"

  sudo pacman -S --noconfirm flatpak

  echo -e "${SUCC} Flatpak installed successfully, reboot your computer and execute this script again to install the Flathub Apps!${NC}"
fi
