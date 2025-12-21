# Shared zsh configuration

# Set global config dir
export XDG_CONFIG_HOME="$HOME/.config"

# Path
export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Source host-specific configuration
[ -f ~/.osconfig/.zshrc ] && source ~/.osconfig/.zshrc
