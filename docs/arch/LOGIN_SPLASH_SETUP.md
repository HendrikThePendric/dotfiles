# Arch + Hyprland Login & Splash Screen Setup
# Catppuccin Mocha Blue Theme

## Overview
This guide sets up:
1. **SDDM** - Login screen with Catppuccin Mocha theme
2. **Plymouth** - Boot splash screen with Catppuccin theme

---

## 1. SDDM Login Manager Setup

### Install SDDM
```bash
sudo pacman -S sddm qt5-graphicaleffects qt5-quickcontrols2 qt5-svg
```

### Install Catppuccin SDDM Theme
```bash
# Install from AUR (easiest method)
yay -S sddm-catppuccin-git
```

### Configure SDDM
Create/edit SDDM configuration:
```bash
sudo nano /etc/sddm.conf.d/theme.conf
```

Add:
```ini
[Theme]
Current=catppuccin-mocha
CursorTheme=Catppuccin-Mocha-Blue-Cursors

[General]
InputMethod=
```

### Customize Theme Colors (Blue Accent)
```bash
sudo nano /usr/share/sddm/themes/catppuccin-mocha/theme.conf
```

Ensure accent color is blue (89b4fa):
```ini
[General]
AccentColor=#89b4fa
BackgroundColor=#1e1e2e
```

### Enable SDDM
```bash
sudo systemctl enable sddm.service
```

---

## 2. Plymouth Boot Splash Setup

### Install Plymouth
```bash
sudo pacman -S plymouth
```

### Install Catppuccin Plymouth Theme
```bash
# Clone catppuccin plymouth theme
cd /tmp
git clone https://github.com/catppuccin/plymouth.git
cd plymouth

# Install Mocha theme
sudo cp -r themes/catppuccin-mocha /usr/share/plymouth/themes/
sudo plymouth-set-default-theme -R catppuccin-mocha
```

### Configure GRUB for Plymouth
Edit GRUB config:
```bash
sudo nano /etc/default/grub
```

Modify the `GRUB_CMDLINE_LINUX_DEFAULT` line to include `splash`:
```bash
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 rd.udev.log_priority=3 vt.global_cursor_default=0"
```

Regenerate GRUB config:
```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Configure mkinitcpio
Edit `/etc/mkinitcpio.conf`:
```bash
sudo nano /etc/mkinitcpio.conf
```

Add `plymouth` to HOOKS (after `base` and `udev`, before `filesystems`):
```bash
HOOKS=(base udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block filesystems fsck)
```

Rebuild initramfs:
```bash
sudo mkinitcpio -P
```

---

## 3. Additional Customization

### Set Catppuccin Cursor Theme
```bash
yay -S catppuccin-cursors-mocha
```

Add to your dotfiles (Hyprland config):
```bash
# In hyprland.conf
env = XCURSOR_THEME,Catppuccin-Mocha-Blue-Cursors
env = XCURSOR_SIZE,24
```

### Set GTK Theme
```bash
yay -S catppuccin-gtk-theme-mocha
```

---

## 4. Testing

### Test SDDM theme
```bash
sddm-greeter --test-mode --theme /usr/share/sddm/themes/catppuccin-mocha
```

### Preview Plymouth
```bash
sudo plymouth quit
sudo plymouthd
sudo plymouth show-splash
# Wait a few seconds
sudo plymouth quit
```

---

## 5. Reboot
```bash
sudo reboot
```

You should now see:
1. **Plymouth splash** during boot (Catppuccin Mocha animated logo)
2. **SDDM login screen** with Catppuccin Mocha theme (blue accent)
3. **Hyprland** with matching theme

---

## Automated Setup

Run the automated setup script:
```bash
sudo ~/projects/dotfiles/scripts/arch/setup-login-splash.sh
```

This script handles all the above steps automatically.
