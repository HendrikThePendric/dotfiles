# Dotfiles

Personal dotfiles managed via a symlink-based approach, supporting multiple operating systems (Arch Linux with Hyprland, macOS, and Ubuntu) while maintaining a unified configuration workflow.

## Philosophy

This repository implements a flexible dotfiles management system that balances sharing common configurations across hosts while accommodating platform-specific needs. Rather than using a bare git repository approach or manual copying, this system uses automated symlinking to maintain a clean separation between version-controlled configurations and the actual system files.

## How It Works

The dotfiles management system is built around three key concepts:

### 1. Shared Configurations

Files in the `shared/` directory contain configurations common to all systems. The sync script creates symlinks directly from these files to your home directory, ensuring consistency across all your machines.

```
shared/.zshrc → ~/.zshrc
shared/.gitconfig → ~/.gitconfig
shared/.config/nvim/ → ~/.config/nvim/
```

### 2. Host-Specific Overrides

For configurations that need platform-specific customization, the system supports a `.local` suffix pattern:

- Host-specific files (in `arch/`, `macos/`, or `ubuntu/`) that **also exist** in `shared/` are symlinked with a `.local` extension
- The shared configuration then imports or includes the `.local` version
- This allows shared defaults with host-specific extensions

```
macos/.zshrc → ~/.zshrc.local (sourced by shared ~/.zshrc)
macos/.gitconfig → ~/.gitconfig.local (included by shared ~/.gitconfig)
macos/.config/kitty/kitty.conf → ~/.config/kitty/kitty.conf.local (included by shared kitty.conf)
```

### 3. Host-Only Configurations

Host-specific files that **don't exist** in `shared/` are symlinked directly with their original name, allowing for platform-unique configurations without affecting other systems.

```
arch/.config/hypr/ → ~/.config/hypr/ (Hyprland only on Arch)
macos/.zshrc.env → ~/.zshrc.env (Homebrew paths only on macOS)
```

## Quick Start

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/HendrikThePendric/dotfiles.git ~/Apps/dotfiles
   cd ~/Apps/dotfiles
   ```

2. **Run the sync script:**
   ```bash
   ./scripts/sync-to-host.sh
   ```

   The script will:
   - Detect your operating system automatically
   - Back up any existing configurations to `.BAK` files
   - Create all necessary symlinks
   - Track created symlinks in `.symlinks.txt`

3. **Install required packages:**
   - **Arch Linux**: See [docs/arch/SETUP.md](docs/arch/SETUP.md) for automated setup
   - **macOS**: Install packages from [docs/macos/Brewfile](docs/macos/Brewfile) with `brew bundle --file=docs/macos/Brewfile`
   - **All platforms**: Review [docs/PACKAGES.md](docs/PACKAGES.md) for comprehensive package documentation

### Syncing Changes

After modifying any configuration in the repository, re-run the sync script:

```bash
cd ~/Apps/dotfiles
./scripts/sync-to-host.sh
```

The script intelligently handles updates without recreating existing symlinks.

## Repository Structure

```
dotfiles/
├── shared/          # Cross-platform configurations
│   ├── .zshrc
│   ├── .gitconfig
│   ├── .tmux.conf
│   └── .config/
│       ├── nvim/    # Neovim (LazyVim)
│       ├── kitty/   # Kitty terminal
│       ├── starship/# Starship prompt
│       └── ...
├── arch/            # Arch Linux specific
│   ├── .gitconfig   # Personal email, no GPG
│   └── .config/
│       ├── hypr/    # Hyprland compositor
│       └── ...
├── macos/           # macOS specific
│   ├── .zshrc       # Work aliases
│   ├── .zshrc.env   # Homebrew paths
│   ├── .gitconfig   # Work email, GPG signing
│   └── .config/
│       └── kitty/
│           └── kitty.conf  # macOS-specific font/key settings
├── ubuntu/          # Ubuntu specific
├── scripts/
│   └── sync-to-host.sh  # Main sync script
└── docs/
    ├── PACKAGES.md        # Package documentation
    ├── arch/
    │   └── SETUP.md       # Arch Linux setup guide
    └── macos/
        └── Brewfile       # Homebrew packages
```

## Key Tools & Technologies

This configuration leverages:

- **Shell**: zsh with antidote plugin manager
- **Terminal**: kitty with Catppuccin Mocha theme
- **Multiplexer**: tmux with TPM (Tmux Plugin Manager)
- **Editor**: neovim with LazyVim distribution
- **Prompt**: starship with context-aware configs
- **Version Control**: git with delta pager, lazygit TUI
- **Theme**: Catppuccin Mocha consistently across all tools

## Adding New Configurations

### For All Systems

1. Add the file to `shared/`
2. Run `./scripts/sync-to-host.sh`
3. Commit and push

### For Specific Systems with Shared Base

1. Create the base configuration in `shared/`
2. Add an include or source directive for the `.local` version
3. Create the host-specific override in `arch/`, `macos/`, or `ubuntu/`
4. Run the sync script
5. Commit and push

### For Platform-Exclusive Features

1. Add the file to the appropriate host directory (`arch/`, `macos/`, or `ubuntu/`)
2. Run the sync script
3. Commit and push

## Documentation

- **[docs/PACKAGES.md](docs/PACKAGES.md)** - Comprehensive package list with installation instructions
- **[docs/arch/SETUP.md](docs/arch/SETUP.md)** - Arch Linux installation guide
- **[docs/arch/LOGIN_SPLASH_SETUP.md](docs/arch/LOGIN_SPLASH_SETUP.md)** - SDDM and splash screen configuration
- **[docs/macos/Brewfile](docs/macos/Brewfile)** - Homebrew package manifest