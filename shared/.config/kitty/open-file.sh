#!/bin/zsh
# Wrapper to open files in Neovim with proper environment
# This script sources .zshrc to get full shell environment

# Source shell config to get PATH and environment variables
source ~/.zshrc

# Find nvim in PATH (now that PATH is loaded from .zshrc)
# This works across macOS (Homebrew), Ubuntu, and Arch Linux
if command -v nvim &> /dev/null; then
    exec nvim "$@"
else
    # Fallback: try common locations
    for nvim_path in /opt/homebrew/bin/nvim /usr/bin/nvim /usr/local/bin/nvim; do
        if [[ -x "$nvim_path" ]]; then
            exec "$nvim_path" "$@"
        fi
    done
    
    # If we get here, nvim wasn't found
    echo "Error: nvim not found in PATH or common locations" >&2
    exit 1
fi