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
pacman -S --noconfirm sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg

# Install Plymouth
echo "Installing Plymouth..."
pacman -S --noconfirm plymouth

# Install Catppuccin SDDM theme from AUR (as the user who invoked sudo)
echo "Setting up SDDM theme from AUR..."
REAL_USER="${SUDO_USER:-$USER}"
sudo -u "$REAL_USER" yay -S --noconfirm sddm-catppuccin-git

# Configure SDDM
echo "Configuring SDDM..."
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/theme.conf << 'EOF'
[Theme]
Current=catppuccin-mocha

[General]
InputMethod=
EOF

# Customize theme for Mocha with blue accent
echo "Customizing theme colors..."
cat > /usr/share/sddm/themes/catppuccin-mocha/theme.conf.user << 'EOF'
[General]
Background="backgrounds/squares.png"
Font="Noto Sans"
Padding="50"
CornerRadius="8"
GeneralFontSize="10"
LoginScale="0.175"

# Catppuccin Mocha with Blue accent
UserPictureBorderWidth="5"
UserPictureBorderColor="#89b4fa"
UserPictureColor="#89b4fa"

AccentColor="#89b4fa"
MainColor="#cdd6f4"
BackgroundColor="#1e1e2e"
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
