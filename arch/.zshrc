# Arch-specific zsh configuration

# SSH Agent via systemd
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Auto-add SSH key if not already loaded U
if ! ssh-add -l &>/dev/null; then
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
