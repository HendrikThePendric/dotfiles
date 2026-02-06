# Arch Linux Setup

This guide covers setting up a fresh Arch Linux installation with these dotfiles.

## Prerequisites

A bare Arch Linux installation with an active internet connection.

## Installation Steps

### 1. Install Git

```bash
sudo pacman -S git
```

### 2. Clone Repository

```bash
git clone https://github.com/HendrikThePendric/dotfiles.git ~/Apps/dotfiles
cd ~/Apps/dotfiles
```

### 3. Run Setup Script

The automated setup script will:
- Install all required packages (Hyprland, kitty, neovim, etc.)
- Configure the system
- Create symlinks for all dotfiles

```bash
sudo ./arch/.config/scripts/setup-host.sh
```

### 4. Post-Installation

After the setup script completes:

1. Restart your system to load the new environment
2. Log in to your Hyprland session
3. Verify all tools are working correctly

## Manual Sync

If you make changes to the dotfiles repository, resync with:

```bash
cd ~/Apps/dotfiles
./scripts/sync-to-host.sh
```

## Related Documentation

- [Login & Splash Screen Setup](LOGIN_SPLASH_SETUP.md) - Configure SDDM and splash screen
