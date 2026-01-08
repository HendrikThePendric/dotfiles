# ============================================================================
# ZSH Configuration - Shared
# ============================================================================

# Load host-specific environment variables and early setup
# This file is sourced first and should contain:
# - PATH modifications
# - Environment variables
# - Host-specific exports
[[ -f ~/.zshrc.env ]] && source ~/.zshrc.env

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
if [[ -n $TMUX ]]; then
    export STARSHIP_CONFIG=~/.config/starship/config_tmux.toml
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
