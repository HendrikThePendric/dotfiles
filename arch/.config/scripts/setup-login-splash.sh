#!/bin/bash
# Setup script for SDDM + Plymouth with Catppuccin Mocha theme
# Run with sudo

set -e

echo "================================================"
echo "Installing SDDM + Plymouth with Catppuccin Mocha"
echo "================================================"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./setup-login-splash.sh)"
    exit 1
fi

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "Error: yay is not installed. Please install yay first."
    exit 1
fi

# Install SDDM
echo "Installing SDDM..."
pacman -S --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg qt6-svg qt6-declarative

# Install Plymouth
echo "Installing Plymouth..."

pacman -S --noconfirm plymouth

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

# Enable SDDM service
echo "Enabling SDDM service..."
systemctl enable sddm.service

echo ""
echo "================================================"
echo "Installation complete!"
echo "================================================"
echo ""
echo "Optional: Install Catppuccin cursors and GTK theme"
echo "  yay -S catppuccin-cursors-mocha catppuccin-gtk-theme-mocha"
echo ""
echo "To test SDDM theme:"
echo "  sddm-greeter --test-mode --theme /usr/share/sddm/themes/catppuccin-mocha"
echo ""
echo "Reboot to see the changes!"
echo ""
