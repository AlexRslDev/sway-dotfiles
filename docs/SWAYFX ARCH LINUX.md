### SWAYFX + ARCH LINUX ###

1. archinstall (minimal config).
2. Install swayfx:
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
yay -S swayfx
3. Install another important dependencies
sudo pacman -S kitty pavucontrol waybar xorg-xwayland neovim python grim swappy wl-clipboard
4. Initial Configuration File
mkdir -p ~/.config/sway
cp -r /etc/sway/* ~/.config/sway
nvim ~/.config/sway/config
-- then replace set $term foot -- to -- set $term kitty
5. Setting the condig file ...
6. Git clone to my repo to get the waybar files:
git clone https://github.com/AlexRslDev/sway-dotfiles.git
cd sway-dotfiles
cp -r .config/waybar ~/.config
7. Install swww for wallpapers:
sudo pacman -S swww
8. Install Custom Manual Fonts:
mkdir -p ~/.local/share/fonts
cp -r ~/sway-dotfile/.local/share/fonts/* ~/.local/share/fonts
fc-cache -fv
fc-list | grep "font_name"
NOTE: you cange change the font-family into waybar styles (optional)
9. Notifications
sudo pacman -S dunst libnotify
mkdir -p ~/.config/dunst
touch ~/.config/dunst/dunstrc
... dotfiles ...
-- test notifications --
notify-send "hello world from dunst"
NOTES:
-- Close the last notification or all o them --
bindsym $mod+backslasg exec dunstctl close
bindsym $mod+Shift+backslash exec dunstctl close-all
-- View notications history --
bindsym $mod+grave exec dunstctl history-pop
10. Install Session manager (ly)
sudo pacman -S ly
11. Install lock screen:
sudo pacman -S gtklock
12. Install swayidle:
sudo pacman -S swayidle
13. Install wlogout:
yay -S wlogout
14. Install wine and lutris:
sudo pacman -S wine wine-gecko winetricks lutris
15. Install network manager:
sudo pacman -S networkmanager network-manager-applet
sudo systemctl enable NetworkManager.service
sudo systemctl start NetworkManager.service
-- to disable --
sudo systemctl stop dhcpcd.service
sudo systemctl disable dhcpcd.service

