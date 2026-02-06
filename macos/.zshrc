# ============================================================================
# macOS ZSH Configuration - Local Overrides
# ============================================================================
# This file is sourced at the END of shared .zshrc
# Use for: machine-specific aliases, functions, and environment variables
# Last updated: 2025-02-06
# ============================================================================

# ----------------------------------------------------------------------------
# DHIS2 Development Aliases
# ----------------------------------------------------------------------------

# Build with custom timestamp version
alias custom_build='sed -i '' "s/\"version\": \".*\"/\"version\": \"999.9.9-$(date '+%Y-%m-%dT%H-%M-%S')\"/" package.json && yarn build'

# Sync And Watch - watch analytics library changes
alias saw='yarn install --force && rm -rf node_modules/@dhis2/analytics/node_modules && npx chokidar-cli "../analytics/build/**/*" -c "rm -rf node_modules/@dhis2/analytics/build && cp -R ../analytics/build/ node_modules/@dhis2/analytics/build" --initial'

# Replace Analytics Workspace - copy analytics build
alias raw='rm -rf node_modules/@dhis2/analytics/build && cp -R ../analytics/build/ node_modules/@dhis2/analytics/build'

# Sync And Watch - watch maps-gl library changes
alias sawmap='yarn install --force && rm -rf node_modules/@dhis2/maps-gl/node_modules && npx chokidar-cli "../maps-gl/build/**/*" -c "rm -rf node_modules/@dhis2/maps-gl/build && cp -R ../maps-gl/build/ node_modules/@dhis2/maps-gl/build" --initial'

# Replace Maps Workspace - copy maps-gl build
alias rawmap='rm -rf node_modules/@dhis2/maps-gl/build && cp -R ../maps-gl/build/ node_modules/@dhis2/maps-gl/build'

# DHIS2 Docker shortcuts
alias docker-up-dhis2="cd ~/Apps/dhis2-core && docker compose up -d"
alias docker-logs-dhis2="cd ~/Apps/dhis2-core && docker compose logs web --follow"

# ----------------------------------------------------------------------------
# Docker Utilities
# ----------------------------------------------------------------------------

# Interactive container top
alias ctop="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop:latest"

# Dive into docker images
alias dive="docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest"

# ----------------------------------------------------------------------------
# Media Conversion
# ----------------------------------------------------------------------------

# Convert all MKV files in current directory to MOV (ProRes)
alias convert_mkv_to_mov='for i in *.mkv; do ffmpeg -i "$i" -c:v prores_ks -profile:v 3 -c:a pcm_s24le "${i%.*}.mov"; done'

# ----------------------------------------------------------------------------
# System Utilities
# ----------------------------------------------------------------------------

# Sync with home server (Dobby)
alias dobbysync='ssh dobby "cd homeserver; ./sync_dobby.sh;"'

# OpenVPN management
alias startopenvpn='sudo openvpn --config ~/.openvpn/privado.ovpn --daemon'
alias stopopenvpn='sudo killall openvpn'

# Clean up old tmux resurrect sessions
alias remove-resurrect-sessions="find $HOME/.local/share/tmux/resurrect -name 'tmux_resurrect_*.txt' -delete"

# ----------------------------------------------------------------------------
# Application-Specific Environment Variables
# ----------------------------------------------------------------------------

# DHIS2 configuration directory
export DHIS2_HOME="$HOME/.config/dhis2_home"

# Ollama (local LLM) configuration
export OLLAMA_API_BASE="http://127.0.0.1:11434"
export OLLAMA_NUM_CTX=8192      # Context window size - safe for M1 Max
export OLLAMA_NUM_THREAD=8      # CPU threads - balanced for 10-core CPU
