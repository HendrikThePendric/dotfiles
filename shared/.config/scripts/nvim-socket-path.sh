#!/usr/bin/env bash
# Compute Neovim socket path based on current directory
# Priority: git repo name > directory name > fallback /tmp/nvim

# Get current directory
cwd="$(pwd)"

# Try git repo name first
if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    name="$(basename "$git_root")"
else
    # Fallback to directory name
    name="$(basename "$cwd")"
fi

# Sanitize name (replace non-alphanumeric with _)
name="$(echo "$name" | sed 's/[^a-zA-Z0-9_-]/_/g')"

# If name is empty after sanitization, use fallback
if [ -z "$name" ]; then
    echo "/tmp/nvim"
else
    echo "/tmp/nvim-$name"
fi