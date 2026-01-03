#!/bin/bash
# Setup script for host configuration: SDDM, Plymouth, GTK theme, and system settings
# Run with sudo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"

echo "================================================"
echo "Setting up host: SDDM + Plymouth + GTK theme"
echo "================================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./setup-login-splash.sh)"
    exit 1
fi

# Check if yay is installed, install if not
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    pacman -S --needed git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
fi

# Install additional official packages from packages.txt
echo "Installing additional official packages..."
pacman -S --noconfirm $(cat ~/.config/scripts/packages.txt)

# Install AUR packages from aur-packages.txt
echo "Installing AUR packages..."
yay -S --noconfirm $(cat ~/.config/scripts/aur-packages.txt)

# Ensure CaskaydiaCove Nerd Font is installed
echo "Installing CaskaydiaCove Nerd Font..."
pacman -S --noconfirm ttf-cascadia-code-nerd

# Install Catppuccin SDDM theme from AUR (as the user who invoked sudo)
echo "Setting up SDDM theme from AUR..."

echo "Downloading Catppuccin Mocha Blue SDDM theme..."
cd /tmp
echo "Checking for gh and jq..."
if ! command -v gh &> /dev/null; then
    echo "Error: gh (GitHub CLI) is not installed. Please install gh first."
    exit 1
fi
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq first."
    exit 1
fi
REAL_USER="${SUDO_USER:-$USER}"

# Run sync script to create symlinks early
echo "Running sync script to set up dotfiles symlinks..."
sudo -u "$REAL_USER" "$REPO_ROOT/scripts/sync-to-host.sh"

LATEST_URL=$(sudo -u "$REAL_USER" gh release view --repo catppuccin/sddm --json assets | jq -r '.assets[] | select(.name == "catppuccin-mocha-blue-sddm.zip") | .url')
if [ -z "$LATEST_URL" ]; then
    echo "Error: Could not find latest catppuccin-mocha-blue-sddm.zip release URL."
    exit 1
fi
rm -rf catppuccin-mocha-blue
if [ -f "catppuccin-mocha-blue-sddm.zip" ]; then
    rm "catppuccin-mocha-blue-sddm.zip"
fi
wget "$LATEST_URL" -O catppuccin-mocha-blue-sddm.zip
unzip catppuccin-mocha-blue-sddm.zip
cp -r catppuccin-mocha-blue /usr/share/sddm/themes/


# Configure SDDM
echo "Configuring SDDM..."
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf << 'EOF'
[Theme]
Current=catppuccin-mocha-blue
EOF

# Customize theme for Mocha with blue accent
echo "Customizing theme colors..."
cat > /usr/share/sddm/themes/catppuccin-mocha-blue/theme.conf << 'EOF'
Font="CaskaydiaCove Nerd Font"
FontSize=28
ClockEnabled="true"
CustomBackground="false"
LoginBackground="false"
Background="backgrounds/wall.png"
UserIcon="false"

# Uncomment this option to show the last letter of the password
# for the number of milliseconds specified
# PasswordShowLastLetter=1000
EOF

# Clone and install Catppuccin Plymouth theme
echo "Setting up Plymouth theme..."
cd /tmp
if [ -d "plymouth-catppuccin" ]; then
    rm -rf plymouth-catppuccin
fi
git clone https://github.com/catppuccin/plymouth.git plymouth-catppuccin
cd plymouth-catppuccin

# Install Mocha theme
cp -r themes/catppuccin-mocha /usr/share/plymouth/themes/
plymouth-set-default-theme -R catppuccin-mocha

# Set GTK theme for the user
echo "Setting GTK theme..."
sudo -u "$REAL_USER" gsettings set org.gnome.desktop.interface gtk-theme 'Catppuccin-Mocha-Standard-Blue-Dark'
sudo -u "$REAL_USER" gsettings set org.gnome.desktop.wm.preferences theme 'Catppuccin-Mocha-Standard-Blue-Dark'
sudo -u "$REAL_USER" gsettings set org.gnome.desktop.interface cursor-theme 'Catppuccin-Mocha-Dark-Cursors'

# Configure mkinitcpio
echo "Configuring mkinitcpio..."
if ! grep -q "plymouth" /etc/mkinitcpio.conf; then
    echo "Adding plymouth to mkinitcpio hooks..."
    sed -i 's/^HOOKS=(\(.*\)udev\(.*\))/HOOKS=(\1udev plymouth\2)/' /etc/mkinitcpio.conf
    mkinitcpio -P
else
    echo "Plymouth already in mkinitcpio hooks"
fi

# Update GRUB
echo "Updating GRUB configuration..."
if [ -f /etc/default/grub ]; then
    if ! grep -q "splash" /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="\(.*\)"/GRUB_CMDLINE_LINUX_DEFAULT="\1 quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"/' /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    else
        echo "GRUB already configured for splash"
    fi
fi


# Configure systemd-logind for lid close: suspend
echo "Configuring /etc/systemd/logind.conf for lid close suspend..."
if grep -q '^#*HandleLidSwitch=' /etc/systemd/logind.conf; then
    sed -i 's/^#*HandleLidSwitch=.*/HandleLidSwitch=suspend/' /etc/systemd/logind.conf
else
    echo 'HandleLidSwitch=suspend' >> /etc/systemd/logind.conf
fi
if grep -q '^#*HandleLidSwitchDocked=' /etc/systemd/logind.conf; then
    sed -i 's/^#*HandleLidSwitchDocked=.*/HandleLidSwitchDocked=suspend/' /etc/systemd/logind.conf
else
    echo 'HandleLidSwitchDocked=suspend' >> /etc/systemd/logind.conf
fi
systemctl restart systemd-logind

# Enable user systemd services
echo "Enabling user systemd services..."
sudo -u "$REAL_USER" systemctl --user enable kanata.service
sudo -u "$REAL_USER" systemctl --user enable ssh-add.service

# Enable SDDM service
echo "Enabling SDDM service..."
systemctl enable sddm.service

echo ""
echo "================================================"
echo "Installation complete!"
echo "Reboot to see the changes!"
echo "================================================"
echo ""
