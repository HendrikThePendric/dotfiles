# Dotfiles

This repository contains my personal dotfiles, managed across multiple systems (Arch Linux, Ubuntu, macOS).

## Setup

### Arch Linux

For a bare Arch Linux installation:

1. Install git manually:
   ```
   pacman -S git
   ```

2. Clone this repository:
   ```
   git clone https://github.com/yourusername/dotfiles.git
   cd dotfiles
   ```

3. Run the setup script:
   ```
   sudo ./arch/.config/scripts/setup-host.sh
   ```

This will install all necessary packages, configure the system, and set up symlinks for your dotfiles.

### Other Systems

- **Ubuntu**: Run the appropriate setup script in `ubuntu/`.
- **macOS**: Run the setup script in `macos/`.

## Structure

- `shared/`: Configurations common to all systems.
- `arch/`: Arch Linux specific configurations.
- `ubuntu/`: Ubuntu specific configurations.
- `macos/`: macOS specific configurations.
- `scripts/`: Utility scripts, including `sync-to-host.sh` for managing symlinks.

## Sync Script

The `scripts/sync-to-host.sh` script creates symlinks from the repository files to your home directory. It detects your OS and applies the appropriate configurations.

Run it after cloning to set up symlinks:
```
./scripts/sync-to-host.sh
```

## Adding New Configurations

1. Place files in the appropriate directory (`shared/` for common, or OS-specific).
2. Run the sync script to create symlinks.
3. Commit and push changes.