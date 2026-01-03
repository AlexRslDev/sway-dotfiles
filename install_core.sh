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

LOCAL_CONFIG_DIR="$REAL_HOME/.config"
LOCAL_FONTS_DIR="/usr/share/fonts"
LOCAL_ICONS_DIR="$REAL_HOME/.icons"
CURSOR_THEME="${XCURSOR_THEME:-Adwaita}"
CURSOR_SIZE="${XCURSOR_SIZE:-24}"
ICON_THEME="Gruvbox-Plus-Dark"
GTK3_FILE="$REAL_HOME/.config/gtk-3.0/settings.ini"
GTK4_FILE="$REAL_HOME/.config/gtk-4.0/settings.ini"
URL_ICON_THEME="https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/v6.3.0/gruvbox-plus-icon-pack-6.3.0.zip"
PAM_FILE="/etc/pam.d/login"

THEME="$1"
MODE="$2"

# HELP SECTION
if [[ -z "$THEME" || -z "$MODE" ]]; then
  echo "Usage: apply.sh <theme> <dark|light>"
  exit 1
fi

# CREATE DIRECTORIES IF THEY DOESN'T EXISTS
[ ! -d "$LOCAL_FONTS_DIR" ] && mkdir -p "$LOCAL_FONTS_DIR"
[ ! -d "$LOCAL_ICONS_DIR" ] && mkdir -p "$LOCAL_ICONS_DIR"

# INSTALL CORE DEPENDENCIES
echo -e "${INST} Updating System...${NC}"
sudo pacman -Syu --noconfirm
echo -e "${SUCC} Sucessfull Update!${NC}"

# INSTALL YAY
echo -e "${INST} Installing yay...${NC}"
sudo -u "$REAL_USER" git clone https://aur.archlinux.org/yay.git /tmp/yay
(cd /tmp/yay && sudo -u "$REAL_USER" makepkg -si --noconfirm)
rm -rf /tmp/yay
echo -e "${SUCC} Sucessfull Installation!${NC}"

echo -e "${INST} Installing Core Dependencies...${NC}"
sudo pacman -S --noconfirm --needed wayland-protocols wlroots qt5-wayland qt6-wayland qt5ct qt6ct xorg-xwayland kitty pipewire wireplumber pipewire-pulse pavucontrol xdg-desktop-portal gnome-keyring libsecret seahorse polkit-kde-agent dunst libnotify grim slurp waybar git jq neovim curl wget gcc make cmake fastfetch swww rofi cliphist wlogout fzf gwenview qt6-imageformats unzip python grim swappy wl-clipboard gammastep gtklock swayidle
echo -e "${SUCC} Sucessfull Installation!${NC}"

# INSTALL NETWORK MANAGER
sudo pacman -S --noconfirm --needed networkmanager network-manager-applet
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service

# OPTION TO INSTALL BLUEHOOTH
read -p "Do you want to install Bluetooth Dependencies? (y/n): " bthAns
if [[ "${bthAns,,}" == "y" ]]; then

  echo -e "${INST} Installing Bluetooth Dependencies...${NC}"
  sudo pacman -S --noconfirm --needed blueman
  echo -e "${SUCC} Sucessfull Installation!${NC}"
fi

# CONFIG GNOME KEYRING
if ! grep -q "^auth.*pam_gnome_keyring.so" "$PAM_FILE"; then
  echo "auth       optional     pam_gnome_keyring.so" >>"$PAM_FILE"
fi

if ! grep -q "pam_gnome_keyring.so auto_start" "$PAM_FILE"; then
  echo "session    optional     pam_gnome_keyring.so auto_start" >>"$PAM_FILE"
fi

# OPTION TO INSTALL FLATPAK FLATHUB
read -p "Do you want to install Flatpak and Flathub? (y/n): " flakpflath
if [[ "${flakpflath,,}" == "y" ]]; then
  echo -e "${INST} Installing Flatpak and Flathub...${NC}"
  sudo pacman -S --noconfirm --needed flatpak
  echo -e "${SUCC} Sucessfull Installation!${NC}"
fi

# CHOOSE A FILE MANAGER
echo "File Managers"
echo "1) Dolphin"
echo "2) Nautilus"
echo "3) Thunar"
echo "4) Yazy"
read -p "Select a File Manager [1-4]:" fmOption

case $fmOption in
1)
  echo -e "${INST} Installing dolphin...${NC}"
  sudo pacman -S --noconfirm --needed dolphin ark ffmpegthumbs kdegraphics-thumbnailers
  echo -e "${SUCC} Sucessfull Installation!${NC}"
  ;;
2)
  echo -e "${INST} Installing nautilus...${NC}"
  sudo pacman -S --noconfirm --needed nautilus gvfs file-roller sushi
  echo -e "${SUCC} Sucessfull Installation!${NC}"
  ;;
3)
  echo -e "${INST} Installing thunar...${NC}"
  sudo pacman -S --noconfirm --needed thunar gvfs thunar-volman thunar-archive-plugin tumbler
  echo -e "${SUCC} Sucessfull Installation!${NC}"
  ;;
4)
  echo -e "${INST} Installing yazi...${NC}"
  sudo pacman -S --noconfirm --needed yazi ffmpegthumbnailer imagemagick poppler fd ripgrep
  echo -e "${SUCC} Sucessfull Installation!${NC}"
  ;;
*)
  echo -e "${WARN} Invalid Option.${NC}"
  ;;
esac

# INSTALL SESSION MANAGER
echo -e "${INST} Installing Session Manager...${NC}"
sudo pacman -S --noconfirm --needed ly
sudo systemctl enable ly@tty2.service
echo -e "${SUCC} Sucessfull Installation!${NC}"

# INSTALL DOTFILES
echo -e "${INST} Installing Dotifiles...${NC}"
cp -rv ./.config/* "$LOCAL_CONFIG_DIR/"

# INSTALL FONTS
echo -e "${INST} Installing Fonts...${NC}"
cp -rv ./.local/share/fonts/* "$LOCAL_FONTS_DIR/"
fc-cache -fv
echo -e "${SUCC} Fonts Installed Successfully!${NC}"

# INSTALL CURSOR
cp -rv ./.icons/* "$LOCAL_ICONS_DIR/"
for FILE in "$GTK3_FILE" "$GTK4_FILE"; do
  mkdir -p "$(dirname "$FILE")"

  # Create file if it doesn't exist
  if [ ! -f "$FILE" ]; then
    echo "[Settings]" >"$FILE"
  fi

  # Ensure section [Settings]
  if ! grep -q "^\[Settings\]" "$FILE"; then
    sed -i '1i [Settings]' "$FILE"
  fi

  # gtk-cursor-theme-name
  if grep -q "^gtk-cursor-theme-name=" "$FILE"; then
    sed -i "s/^gtk-cursor-theme-name=.*/gtk-cursor-theme-name=$CURSOR_THEME/" "$FILE"
  else
    sed -i "/^\[Settings\]/a gtk-cursor-theme-name=$CURSOR_THEME" "$FILE"
  fi

  # gtk-cursor-theme-size
  if grep -q "^gtk-cursor-theme-size=" "$FILE"; then
    sed -i "s/^gtk-cursor-theme-size=.*/gtk-cursor-theme-size=$CURSOR_SIZE/" "$FILE"
  else
    sed -i "/^\[Settings\]/a gtk-cursor-theme-size=$CURSOR_SIZE" "$FILE"
  fi
done
echo -e "${SUCC} Cursor Installed Successfully, reboot to apply the changes.${NC}"

# INSTALL GRUVBOX ICONS PACK
echo -e "${INST} Installing Gruvbox Icon pack...${NC}"

curl -LO "$URL_ICON_THEME"
unzip -q gruvbox-plus-icon-pack-6.3.0.zip
cp -rv ./Gruvbox-Plus-Dark ./Gruvbox-Plus-Light "$LOCAL_ICONS_DIR/"

for FILE in "$GTK3_FILE" "$GTK4_FILE"; do
  mkdir -p "$(dirname "$FILE")"

  if [ ! -f "$FILE" ]; then
    echo "[Settings]" >"$FILE"
  fi

  if ! grep -q "^\[Settings\]" "$FILE"; then
    sed -i '1i [Settings]' "$FILE"
  fi

  if grep -q "^gtk-icon-theme-name=" "$FILE"; then
    sed -i "s/^gtk-icon-theme-name=.*/gtk-icon-theme-name=$ICON_THEME/" "$FILE"
  else
    sed -i "/^\[Settings\]/a gtk-icon-theme-name=$ICON_THEME" "$FILE"
  fi
done

rm gruvbox-plus-icon-pack-6.3.0.zip
echo -e "${SUCC} Icon Pack Installed Successfully!${NC}"
