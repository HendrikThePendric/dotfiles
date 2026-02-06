# Package Requirements

This document lists all packages/dependencies required for the shared dotfiles configuration.

## Core Requirements

### Shell & Terminal Tools

| Package | Purpose | Used In |
|---------|---------|---------|
| `zsh` | Primary shell | All configs |
| `antidote` | Fast ZSH plugin manager | [.zshrc](/.zshrc) |
| `starship` | Modern shell prompt | [.zshrc](/.zshrc) |
| `zoxide` | Smart directory jumper | [.zshrc](/.zshrc) |
| `fzf` | Fuzzy finder | [.zshrc](/.zshrc), zsh plugins |
| `direnv` | Per-directory environments | [.zshrc](/.zshrc) |

### Terminal Emulator & Multiplexer

| Package | Purpose | Used In |
|---------|---------|---------|
| `kitty` | GPU-accelerated terminal | [.config/kitty/](.config/kitty/) |
| `tmux` | Terminal multiplexer | [.tmux.conf](.tmux.conf) |
| `gitmux` | Git status in tmux bar | [.tmux.conf](.tmux.conf), [.gitmux.conf](.gitmux.conf) |

### Editor & Development

| Package | Purpose | Used In |
|---------|---------|---------|
| `neovim` (0.9+) | Modern vim editor | [.config/nvim/](.config/nvim/) |
| `bat` | Better cat with syntax | [.config/bat/](.config/bat/), [.gitconfig](.gitconfig) |
| `git-delta` | Git diff pager | [.gitconfig](.gitconfig) |
| `lazygit` | Git TUI | [.config/lazygit/](.config/lazygit/) |
| `gh` | GitHub CLI | Used in scripts |

### Version Managers

| Package | Purpose | Used In |
|---------|---------|---------|
| `pyenv` | Python version manager | [.zshrc](.zshrc) (optional) |
| NVM | Node version manager | Via zsh plugin `lukechilds/zsh-nvm` |

### Additional Dependencies

| Package | Purpose | Used In |
|---------|---------|---------|
| `ripgrep` | Fast grep alternative | LazyVim dependency |
| `fd` | Fast find alternative | LazyVim dependency |
| `node` | JavaScript runtime | LazyVim, development |
| `jq` | JSON processor | Various scripts |

## ZSH Plugins

Managed via antidote, defined in [.zsh_plugins.txt](.zsh_plugins.txt):

- **mattmc3/zephyr** - Core utilities (completion, editor, directory)
- **jeffreytse/zsh-vi-mode** - Vi keybindings
- **zsh-users/zsh-syntax-highlighting** - Syntax highlighting
- **zsh-users/zsh-autosuggestions** - Command suggestions
- **Aloxaf/fzf-tab** - FZF-powered tab completion
- **zsh-users/zsh-completions** - Additional completions
- **zsh-users/zsh-history-substring-search** - History search
- **lukechilds/zsh-nvm** - Node version manager
- **ohmyzsh/ohmyzsh** plugins - sudo, tmux, docker

## Tmux Plugins

Managed via TPM (Tmux Plugin Manager), defined in [.tmux.conf](.tmux.conf):

> **Installation Required:** Clone TPM first:
> ```bash
> git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
> ```

- **tmux-plugins/tpm** - Plugin manager
- **tmux-plugins/tmux-sensible** - Sensible defaults
- **christoomey/vim-tmux-navigator** - Seamless vim/tmux navigation
- **tmux-plugins/tmux-resurrect** - Session persistence
- **tmux-plugins/tmux-continuum** - Auto-save/restore
- **tmux-plugins/tmux-sessionist** - Session management
- **catppuccin/tmux** - Catppuccin Mocha theme

After starting tmux, press `Prefix + I` (Ctrl+a then Shift+I) to install plugins.

## Fonts

Terminal configs use **Nerd Fonts** for icons and glyphs:

- **Linux (Arch):** `ttf-cascadia-code-nerd` → Font name: `CaskaydiaCove Nerd Font`
- **macOS:** Regular Cascadia Code + Symbols Nerd Font (via symbol_map in kitty)
  - Install Symbols Nerd Font from: https://github.com/ryanoasis/nerd-fonts/releases
  - Download: "NerdFontsSymbolsOnly.zip"
- **Ubuntu:** Install via [Nerd Fonts releases](https://github.com/ryanoasis/nerd-fonts/releases)

> ⚠️ Font names differ by OS! Host-specific kitty configs handle this.

## Themes

All configs use **Catppuccin Mocha** theme for consistent look:

- Kitty: [catppuccin-mocha.conf](.config/kitty/catppuccin-mocha.conf)
- Starship: Defined in [config.toml](.config/starship/config.toml)
- Tmux: Via catppuccin/tmux plugin
- LazyGit: [config.yml](.config/lazygit/config.yml)
- ZSH syntax highlighting: [catppuccin_mocha-zsh-syntax-highlighting.zsh](.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh)
- FZF: Colors in [.zshrc](.zshrc)
- Git delta: Catppuccin Mocha theme in [.gitconfig](.gitconfig)
- Bat: Requires Catppuccin Mocha theme installation (see below)

### Bat Theme Setup

After installing `bat`, add the Catppuccin theme:

```bash
mkdir -p "$(bat --config-dir)/themes"
cd "$(bat --config-dir)/themes"
curl -O https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme
bat cache --build
```

## Platform-Specific Installation

### macOS (Homebrew)

```bash
# Install all required packages
brew bundle install --file=macos/Brewfile

# Install TPM for tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

### Arch Linux

Package lists maintained in [arch/.config/scripts/](arch/.config/scripts/):
- [packages.txt](arch/.config/scripts/packages.txt) - Official packages
- [aur-packages.txt](arch/.config/scripts/aur-packages.txt) - AUR packages

### Ubuntu

Antidote path should be set to `/usr/share/zsh-antidote` in `ubuntu/.zshrc.env`.

## Verification

After installation, verify key tools are available:

```bash
# Core shell tools
command -v antidote && echo "✓ antidote"
command -v starship && echo "✓ starship"
command -v zoxide && echo "✓ zoxide"
command -v fzf && echo "✓ fzf"

# Development tools
command -v nvim && echo "✓ neovim"
command -v tmux && echo "✓ tmux"
command -v lazygit && echo "✓ lazygit"
command -v delta && echo "✓ git-delta"
command -v bat && echo "✓ bat"

# Check TPM installation
test -d ~/.tmux/plugins/tpm && echo "✓ TPM installed"
```
