# Dotfiles Repository - OpenCode Agent Instructions

## Repository Overview

This is a dotfiles management repository using a symlink-based approach to manage configurations across multiple systems (macos, ubuntu, arch).

**Supported Systems:**
- **macos** - MacOS work setup
- **ubuntu** - Ubuntu system  
- **arch** - Arch Linux with Hyprland

## Key Concepts

### Directory Structure
```
dotfiles/
├── shared/           # Configurations used across all systems
├── macos/            # MacOS-specific configurations
├── ubuntu/           # Ubuntu-specific configurations
├── arch/             # Arch Linux-specific configurations
├── scripts/          # Management scripts (sync-to-host.sh)
├── empty/            # Generated empty files (gitignored)
├── .symlinks.txt     # Generated symlink tracking (gitignored)
└── BAK/              # Backup of old configs
```

**Key principle:** All host directories (`shared/`, `macos/`, `ubuntu/`, `arch/`) use **identical directory structures and filenames**. This consistency is what makes the system work.

### Configuration Patterns

The location of a file determines its behavior:

1. **Universal Config**: File only exists in `shared/` - works everywhere
   - Examples: `.gitconfig`, `.config/starship/config.toml`

2. **Base + Host Override**: File in `shared/` + host directories - shared config sources from `~/.osconfig/filename`
   - Shared file is the main config, host file contains host-specific additions/overrides
   - Shared config must source from `~/.osconfig/filename`
   - Examples: `.zshrc`, `.config/nvim/lua/config/options.lua`

3. **Fully Host-Specific**: File only in host directories - completely different per host
   - Examples: Hyprland config only on arch, specific scripts per OS

## Agent Guidelines

### When Working with This Repository

1. **Always maintain identical directory structures** across `shared/`, `macos/`, `ubuntu/`, and `arch/` directories
2. **Follow the configuration patterns** described above when adding new files
3. **Use the sync script** after making changes: `./scripts/sync-to-host.sh`
4. **Preserve symlink relationships** - files are symlinked to home directory

### Common Tasks

#### Adding New Configuration Files
- Determine which pattern to use (universal, base+override, or host-specific)
- Create files in appropriate directories with identical paths
- For base+override patterns, add sourcing logic to shared file
- Run sync script to create symlinks

#### Modifying Existing Configurations
- Edit files directly in the repository (they're symlinked)
- Changes take effect immediately
- Run sync script if directory structure changes

#### Testing Changes
- Changes are live immediately due to symlinks
- No build/compile step needed
- Test on actual target systems when possible

### Important Notes
- The `~/.osconfig` directory is used for host-specific overrides
- Empty files are automatically created for hosts that need them
- Existing files are backed up to `.BAK` suffix before symlinking
- Always commit changes to git after testing

### Script Usage
- Main sync script: `./scripts/sync-to-host.sh`
- Automatically detects current host (macos/ubuntu/arch)
- Creates appropriate symlinks based on configuration patterns
- Updates `.symlinks.txt` tracking file

## Quick Reference

### Adding a new config file
1. **Decide on pattern**: Universal, base+override, or host-specific?
2. **Create file(s)** in appropriate directory(ies)
3. **If base+override**: Add sourcing logic to shared file
4. **Run sync**: `./scripts/sync-to-host.sh`
5. **Commit and push** to git

### Creating a host-specific override
1. **Ensure base file exists** in `shared/` with sourcing logic
2. **Create override file** in `host-dir/` with same path/filename
3. **Run sync**: `./scripts/sync-to-host.sh`
4. **Commit and push** to git