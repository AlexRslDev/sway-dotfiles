#!/usr/bin/env bash

# Color definitions
INST='\033[0;34m' # Blue for Installing
SUCC='\033[0;32m' # Green for Success
WARN='\033[1;33m' # Yellow for Reminders/Warnings
ERR='\033[0;31m'  # Red for Errors
NC='\033[0m'      # No Color

# HELP SECTION
if [[ -z "$THEME" || -z "$MODE" ]]; then
  echo "Usage: apply.sh <theme> <dark|light>"
  exit 1
fi

# VARIABLES
LOCAL_FONTS_DIR="/usr/share/fonts"
LOCAL_SDDM_DIR="usr/share/sddm/themes/silent"
LOCAL_CONFIG_DIR="$HOME/.config"
LOCAL_ICONS_DIR="$HOME/.icons"
CURSOR_THEME="${XCURSOR_THEME:-Adwaita}"
CURSOR_SIZE="${XCURSOR_SIZE:-24}"
ICON_THEME="Gruvbox-Plus-Dark"
GTK3_FILE="$HOME/.config/gtk-3.0/settings.ini"
GTK4_FILE="$HOME/.config/gtk-4.0/settings.ini"
URL_ICON_THEME="https://github.com/SylEleuth/gruvbox-plus-icon-pack/releases/download/v6.3.0/gruvbox-plus-icon-pack-6.3.0.zip"
PAM_FILE="/etc/pam.d/login"
LOCAL_ZSH_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom/plugins}"

THEMES_DIR="$LOCAL_CONFIG_DIR/themes"
WALLPAPERS_DIR="$LOCAL_CONFIG_DIR/wallpapers"
THEME="$1" # gruvbox
MODE="$2"  # dark | light
THEME_DIR="$THEMES_DIR/$THEME"
THEME_SCRIPT="$THEME_DIR/$MODE.sh"

# CREATE DIRECTORIES IF THEY DOESN'T EXISTS
[ ! -d "$LOCAL_FONTS_DIR" ] && mkdir -p "$LOCAL_FONTS_DIR"
[ ! -d "$LOCAL_SDDM_DIR" ] && mkdir -p "$LOCAL_SDDM_DIR"
[ ! -d "$LOCAL_ICONS_DIR" ] && mkdir -p "$LOCAL_ICONS_DIR"

# CHECK IF THIS SCRIPT IS EXECUTING AS ROOT
if [ "$EUID" -ne 0 ]; then
  echo -e "${WARN} Please, run this script using sudo or as root.${NC}"
  exit 1
fi

echo -e "${INST} Updating System...${NC}"
sudo pacman -Syu --noconfirm

echo -e "${INST} Installing Dependencies...${NC}"
sudo pacman -S --noconfirm --needed wayland-protocols wlroots qt5-wayland qt6-wayland qt5ct qt6ct xorg-xwayland uwsm kitty pipewire wireplumber pipewire-pulse pavucontrol hyprland xdg-desktop-portal xdg-desktop-portal-hyprland gnome-keyring libsecret seahorse polkit-kde-agent dunst grim slurp waybar git jq neovim curl wget gcc make cmake fastfetch swww rofi wl-clipboard cliphist wlogout hyprpicker hyprlock hypridle darkman nwg-look fzf gwenview qt6-imageformats flatpak unzip

# OPTION TO INSTALL BLUEHOOTH
read -p "Do you want to install Bluetooth Dependencies? (y/n): " bthAns
if [[ "${bthAns,,}" == "y" ]]; then
  echo "Installing Bluetooth Dependencies..."
  sudo pacman -S --noconfirm --needed blueman
fi

# CONFIG GNOME KEYRING
if ! grep -q "pam_gnome_keyring.so" "$PAM_FILE" | grep -q "auth"; then
  echo "auth       optional     pam_gnome_keyring.so" >>"$PAM_FILE"
fi

if ! grep -q "pam_gnome_keyring.so auto_start" "$PAM_FILE"; then
  echo "session    optional     pam_gnome_keyring.so auto_start" >>"$PAM_FILE"
fi

# OPTION TO INSTALL YAY
if ! command -v yay &>/dev/null; then
  read -p "Do you want to install yay? (y/n): " yayAns

  if [[ "${yayAns,,}" == "y" ]]; then
    echo "Installing yay..."

    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
  fi
fi

# OPTION TO INSTALL FLATPAK FLATHUB
read -p "Do you want to install Flatpak and Flathub? (y/n): " flakpflath
if [[ "${flakpflath,,}" == "y" ]]; then
  echo -e "${INST} Installing Flatpak and Flathub...${NC}"
  sudo pacman -S --noconfirm --needed flatpak
  echo -e "${SUCC} Flatpak and Flathub Installed Successfully!${NC}"
fi

# CHOOSE A FILE MANAGER
echo "File Managers"
echo "1) Dolphin"
echo "2) Nautilus"
echo "3) Thunar"
echo "4) Yazy"
read -p "Select a File Manager [1-3]:" fmOption

case $fmOption in
1)
  sudo pacman -S --noconfirm --needed dolphin ark ffmpegthumbs kdegraphics-thumbnailers
  ;;
2)
  sudo pacman -S --noconfirm --needed nautilus gvfs file-roller sushi
  ;;
3)
  sudo pacman -S --noconfirm --needed thunar gvfs thunar-volman thunar-archive-plugin tumbler
  ;;
4)
  sudo pacman -S --noconfirm --needed yazi ffmpegthumbnailer imagemagick poppler fd ripgrep
  ;;
*)
  echo "Invalid Option."
  ;;
esac

# Install SDDM
echo -e "${INST} Installing SDDM...${NC}"
sudo pacman -S --noconfirm --needed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
sudo systemctl enable sddm

sudo cp -rv ./sddm/* "$LOCAL_SDDM_DIR/"
if [[ -f /etc/sddm.conf ]]; then
  sudo cp -f /etc/sddm.conf /etc/sddm.conf.bkp
  echo -e "Backup for SDDM config saved in '/etc/sddm.conf.bkp'"

  if grep -Pzq '\[Theme\]\nCurrent=' /etc/sddm.conf; then
    sudo sed -i '/^\[Theme\]$/{N;s/\(Current=\).*/\1silent/;}' /etc/sddm.conf
  else
    echo -e "\n[Theme]\nCurrent=silent" | sudo tee -a /etc/sddm.conf
  fi

  if ! grep -Pzq 'InputMethod=qtvirtualkeyboard' /etc/sddm.conf; then
    echo -e "\n[General]\nInputMethod=qtvirtualkeyboard" | sudo tee -a /etc/sddm.conf
  fi

  # "InputMethod" was supposed to automatically set "QT_IM_MODULE", but it doesn't, so we manually export it.
  if ! grep -Pzq 'GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard' /etc/sddm.conf; then
    echo -e "\n[General]\nGreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard" | sudo tee -a /etc/sddm.conf
  fi
else
  echo -e "[Theme]\nCurrent=silent" | sudo tee -a /etc/sddm.conf
  echo -e "\n[General]\nInputMethod=qtvirtualkeyboard" | sudo tee -a /etc/sddm.conf
  echo -e "GreeterEnvironment=QML2_IMPORT_PATH=/usr/share/sddm/themes/silent/components/,QT_IM_MODULE=qtvirtualkeyboard" | sudo tee -a /etc/sddm.conf
fi
echo -e "${SUCC} SDDM Installed Successfully!${NC}"

# COPY .config FOLDER FROM DOTFILES
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

# TERMINAL CONFIG
echo -e "${INST} Installing Zsh Config...${NC}"
sudo pacman -S --noconfirm --needed zsh
chsh -s /usr/bin/zsh

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
cp -rv ./.oh-my-zsh/custom/plugins/* "$LOCAL_ZSH_PLUGINS/"
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin

echo -e "${SUCC} Zsh Config Installed Successfully!${NC}"
