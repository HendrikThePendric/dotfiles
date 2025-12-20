# Dotfiles Repository Instructions

## Philosophy

This repository manages dotfiles across multiple systems using a **symlink-based approach**. The core principle is to keep configuration organized by what's shared versus what's host-specific, while maintaining identical directory structures across all locations.

**Supported Systems:**
- **macos** - MacOS work setup
- **ubuntu** - Ubuntu system  
- **arch** - Arch Linux with Hyprland

## Directory Structure

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

## Organization Rules

The location of a file determines its behavior:

### Pattern 1: Universal Config
**File only exists in `shared/`**
- Same configuration works everywhere
- Examples: `.gitconfig`, `.config/starship/config.toml`

### Pattern 2: Base + Host Override
**File exists in `shared/` AND one or more host directories**
- Shared file is the main config
- Host file contains host-specific additions/overrides
- Shared config must source from `~/.osconfig/filename`
- Examples: `.zshrc`, `.config/nvim/lua/config/options.lua`

### Pattern 3: Fully Host-Specific
**File exists ONLY in host directories (not in `shared/`)**
- Completely different per host
- Examples: Hyprland config only on arch, specific scripts per OS

## Practical Examples

### Example 1: Adding a universal config (zshrc)

If you want the same `.zshrc` everywhere:
```bash
# Create the file
dotfiles/shared/.zshrc

# Run sync
./scripts/sync-to-host.sh

# Result: ~/.zshrc -> dotfiles/shared/.zshrc (on all hosts)
```

### Example 2: Adding host-specific zsh settings

If you want base zsh config + host-specific additions:
```bash
# Create base config
dotfiles/shared/.zshrc
# Add sourcing line at the end:
# [ -f ~/.osconfig/.zshrc ] && source ~/.osconfig/.zshrc

# Create host-specific configs
dotfiles/macos/.zshrc    # MacOS-specific aliases
dotfiles/arch/.zshrc     # Arch-specific PATH additions

# Run sync on arch host
./scripts/sync-to-host.sh

# Result on arch:
# ~/.zshrc -> dotfiles/shared/.zshrc
# ~/.osconfig/.zshrc -> dotfiles/arch/.zshrc
```

### Example 3: Adding nvim config with host overrides

```bash
# Shared nvim config (works everywhere)
dotfiles/shared/.config/nvim/init.lua
dotfiles/shared/.config/nvim/lua/config/options.lua

# Host-specific options
dotfiles/macos/.config/nvim/lua/config/options.lua
dotfiles/arch/.config/nvim/lua/config/options.lua

# In shared/...config/options.lua, add at the end:
# if vim.fn.filereadable(vim.fn.expand("~/.osconfig/.config/nvim/lua/config/options.lua")) == 1 then
#   dofile(vim.fn.expand("~/.osconfig/.config/nvim/lua/config/options.lua"))
# end

# Run sync
./scripts/sync-to-host.sh

# Result: Base config symlinked to shared, overrides available in ~/.osconfig
```

### Example 4: Arch-only Hyprland config

```bash
# Only on arch
dotfiles/arch/.config/hypr/hyprland.conf
dotfiles/arch/.config/hypr/keybinds.conf

# Run sync on arch
./scripts/sync-to-host.sh

# Result: ~/.config/hypr/* -> dotfiles/arch/.config/hypr/*
# (Other hosts won't have these files)
```

## Common Workflows

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

### Switching to new host

1. **Clone repo**: `git clone <repo-url> ~/dotfiles`
2. **Run sync**: `cd ~/dotfiles && ./scripts/sync-to-host.sh`
3. **Done**: All configs are symlinked appropriately for current host

### Making changes to existing configs

1. **Edit files** directly in the repo (they're symlinked)
2. **Changes take effect** immediately
3. **Commit and push** when satisfied

## Important Notes

- **Nested directories**: Fully supported (e.g., `.config/nvim/lua/plugins/...`)
- **Sourcing is manual**: You must add sourcing logic to shared configs yourself
- **Empty files**: Automatically created for hosts that need them (when other hosts have overrides)
- **Existing files**: Backed up to `.BAK` suffix before symlinking
- **~/.osconfig**: Special directory for host-specific overrides

## Reference: Sync Script Details

**Location:** `scripts/sync-to-host.sh`

**What it does:**
1. Removes previous symlinks (from `.symlinks.txt`)
2. Creates symlinks for all `shared/` files to `~` or `~/.config`
3. Creates symlinks for current host files (to `~/.osconfig` if override, otherwise to `~`)
4. Creates empty files + symlinks for missing overrides on current host
5. Tracks all symlinks in `.symlinks.txt`

**Host detection:** Automatic based on OS and distribution (macos/ubuntu/arch)

**Gitignored:** `.symlinks.txt`, `empty/` directory
