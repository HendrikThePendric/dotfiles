# ============================================================================
# ZSH Configuration - Shared
# ============================================================================

# Load host-specific environment variables and early setup
# This file is sourced first and should contain:
# - PATH modifications
# - Environment variables
# - Host-specific exports
[[ -f ~/.zshrc.env ]] && source ~/.zshrc.env

# Load other environment variables
[[ -f ~/.config/env/env.local ]] && source ~/.config/env/env.local

# ============================================================================
# Core Settings
# ============================================================================

# Set XDG base directory
export XDG_CONFIG_HOME="$HOME/.config"

# History
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

# Directory navigation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

# ============================================================================
# Antidote Plugin Manager
# ============================================================================

# ANTIDOTE_DIR should be set in ~/.zshrc.env for each host
# macOS (Apple Silicon): /opt/homebrew/share/antidote
# macOS (Intel):         /usr/local/share/antidote
# Arch Linux:            /usr/share/zsh-antidote
# Ubuntu:                /usr/share/zsh-antidote

# Set up cache directory for oh-my-zsh plugins
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
mkdir -p "$ZSH_CACHE_DIR/completions"

if [[ -n "$ANTIDOTE_DIR" && -f "$ANTIDOTE_DIR/antidote.zsh" ]]; then
    source "$ANTIDOTE_DIR/antidote.zsh"
    antidote load
fi

# opencode
export PATH=/home/hendrik/.opencode/bin:$PATH

# ============================================================================
# Plugin Configuration
# ============================================================================

# Catppuccin Mocha theme for syntax highlighting
[[ -f ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh ]] && source ~/.config/zsh/catppuccin_mocha-zsh-syntax-highlighting.zsh

# Catppuccin Mocha colors for fzf
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1E1E2E,spinner:#F5E0DC,hl:#F38BA8 \
--color=fg:#CDD6F4,header:#F38BA8,info:#CBA6F7,pointer:#F5E0DC \
--color=marker:#B4BEFE,fg+:#CDD6F4,prompt:#CBA6F7,hl+:#F38BA8 \
--color=selected-bg:#45475A \
--color=border:#6C7086,label:#CDD6F4 \
--bind=tab:accept"

# Apply FZF colors to fzf-tab completions
zstyle ':fzf-tab:*' fzf-flags $(echo $FZF_DEFAULT_OPTS)

# History substring search: Use Up/Down arrows to filter history by current input
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ============================================================================
# Better cd-ing
# ============================================================================

eval "$(zoxide init zsh)"

# ============================================================================
# Editor
# ============================================================================

if [[ -n $SSH_CONNECTION ]]; then
    export EDITOR='vim'
    export VISUAL='vim'
else
    export EDITOR='nvim'
    export VISUAL='nvim'
fi

# ============================================================================
# Prompt (Starship)
# ============================================================================

# Select starship config based on context
if [[ -n "$ZELLIJ" || -n "$TMUX" ]]; then
    export STARSHIP_CONFIG=~/.config/starship/config_minimal.toml
else
    export STARSHIP_CONFIG=~/.config/starship/config.toml
fi

# Initialize starship if available
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# ============================================================================
# Tool Initializations
# ============================================================================

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv &> /dev/null; then
    eval "$(pyenv init -)"
fi

# ============================================================================
# Aliases
# ============================================================================

# Editor
alias v='nvim'

# Clear screen and tmux history
alias cs='clear; tmux clear-history 2>/dev/null; clear'

# Direnv: manual loading (via loadenv), automatic unloading (via hook)
eval "$(direnv hook zsh)"
alias loadenv='direnv allow .'

# Docker
alias docker-cleanup='docker stop $(docker ps -a -q) && docker system prune --all --volumes --force'

# Node/JS
alias nuke-nodemodules="find . -name 'node_modules' -type d -prune -exec rm -rf '{}' +"

# ============================================================================
# Load host-specific overrides
# This file is sourced last and should contain:
# - Host-specific aliases
# - Host-specific functions
# - Overrides of shared settings
# ============================================================================

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
