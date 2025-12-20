# Dotfiles Repository Instructions

## Overview

This repository manages dotfiles across multiple systems using a symlink-based approach. It supports three systems:
1. **macos** - MacOS work setup
2. **ubuntu** - Ubuntu system
3. **arch** - Arch Linux with Hyprland

## Repository Structure

```
dotfiles/
├── shared/           # Configurations used across all systems
├── macos/            # MacOS-specific configurations
├── ubuntu/           # Ubuntu-specific configurations
├── arch/             # Arch Linux-specific configurations
├── scripts/          # Management scripts
├── empty/            # Generated empty files (gitignored)
├── .symlinks.txt     # Generated list of created symlinks (gitignored)
└── BAK/              # Backup of old configs (NOT gitignored)
```

All directories (`shared/`, `macos/`, `ubuntu/`, `arch/`) follow the same directory structure and naming conventions, including nested directories (e.g., `.config/nvim/lua/...`).

## Configuration File Logic

The presence of a file in different directories determines its behavior:

### Case 1: File only in `shared/`
- **Meaning**: Same config works on all hosts
- **Action**: Create symlink in `~` or `~/.config` pointing to `shared/filename`

### Case 2: File in `shared/` AND in a host directory
- **Meaning**: The shared file is the main config, which sources host-specific config from the identically named file
- **Action**: 
  - Create symlink in `~` or `~/.config` pointing to `shared/filename`
  - Create symlink in `~/.osconfig` pointing to `hosts/current-host/filename`
  - For other hosts that don't have this file: create an empty file and symlink to it in `~/.osconfig`

### Case 3: File NOT in `shared/` but in one or more host directories
- **Meaning**: File is fully host-specific (may have different versions per host)
- **Action**: Create symlink in `~` or `~/.config` pointing to `hosts/current-host/filename`

## Symlink Management Script

Location: `scripts/setup-symlinks.sh`

### Host Detection
The script determines the current host based on OS and distribution (macos, ubuntu, or arch).

### Script Workflow

#### Step 1: Cleanup
Remove all previously created symlinks by reading `.symlinks.txt` and deleting each symlink listed.

#### Step 2: Process Shared Files
Iterate through all files in `shared/`:
- Create symlinks in `~` or `~/.config` pointing to the shared file
- Record each created symlink in `.symlinks.txt`

#### Step 3: Process Current Host Files
Iterate through files in the current host directory:
- **If** file exists in `shared/`: 
  - This is a host-specific override file
  - Create symlink in `~/.osconfig` pointing to it
- **Else**: 
  - This is a host-unique file
  - Create symlink in `~` or `~/.config` pointing to it
- Record each created symlink in `.symlinks.txt`

#### Step 4: Process Other Hosts (Empty File Generation)
Iterate through files in other host directories:
- **If** file exists in both `shared/` AND the other host directory, but NOT in current host directory:
  - Create an empty file in `empty/` directory
  - Create symlink in `~/.osconfig` pointing to the empty file
- Record each created symlink in `.symlinks.txt`

### Important Notes

1. **Nested Directories**: The script must handle nested directory structures (e.g., `.config/nvim/lua/plugins/init.lua`)

2. **Sourcing Pattern**: How shared configs source host-specific configs is up to each individual config file. The script does NOT automate this. Example pattern:
   ```bash
   # In shared/.bashrc
   [ -f ~/.osconfig/.bashrc ] && source ~/.osconfig/.bashrc
   ```

3. **File Tracking**: Every symlink created in steps 2-4 must be written to `.symlinks.txt` for cleanup on next run.

4. **Directory Creation**: The script should create necessary directories (`~/.osconfig`, `~/.config/...`, `empty/`) as needed.

## Gitignore

The following should be ignored:
- `.symlinks.txt` - Generated file, host-specific
- `empty/` - Generated empty files, host-specific

The following should NOT be ignored:
- `BAK/` - Contains important backup files

## Future Considerations

- Exclude list support may be needed for non-standard cases
- Backup functionality before rolling out to existing systems
- Dry-run mode for previewing changes
