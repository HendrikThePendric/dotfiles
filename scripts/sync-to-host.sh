#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SHARED_DIR="$REPO_ROOT/shared"
EMPTY_DIR="$REPO_ROOT/empty"
SYMLINKS_FILE="$REPO_ROOT/.symlinks.txt"

# Detect current host based on OS and distribution
detect_host() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ -f /etc/os-release ]]; then
        . /etc/os-release
        if [[ "$ID" == "ubuntu" ]]; then
            echo "ubuntu"
        elif [[ "$ID" == "arch" ]]; then
            echo "arch"
        else
            echo -e "${RED}Error: Unsupported distribution: $ID${NC}" >&2
            exit 1
        fi
    else
        echo -e "${RED}Error: Unable to detect operating system${NC}" >&2
        exit 1
    fi
}

# Get all hosts
get_all_hosts() {
    echo "macos ubuntu arch"
}

# Get other hosts (excluding current)
get_other_hosts() {
    local current_host=$1
    local all_hosts=(macos ubuntu arch)
    local other_hosts=()
    
    for host in "${all_hosts[@]}"; do
        if [[ "$host" != "$current_host" ]]; then
            other_hosts+=("$host")
        fi
    done
    
    echo "${other_hosts[@]}"
}

# Create symlink and record it
create_symlink() {
    local target=$1
    local link=$2
    
    # Create parent directory if it doesn't exist
    local link_dir=$(dirname "$link")
    if [[ ! -d "$link_dir" ]]; then
        mkdir -p "$link_dir"
        echo -e "${BLUE}Created directory: $link_dir${NC}"
    fi
    
    # Handle existing files/directories
    if [[ -L "$link" ]]; then
        # Already a symlink, skip
        echo -e "${YELLOW}Warning: $link is already a symlink, skipping${NC}"
        return
    elif [[ -e "$link" ]]; then
        # Existing file or directory, backup it
        local backup="$link.BAK"
        mv "$link" "$backup"
        echo -e "${YELLOW}Backed up existing file: $link -> $backup${NC}"
    fi
    
    # Create symlink
    ln -s "$target" "$link"
    echo "$link" >> "$SYMLINKS_FILE"
    echo -e "${GREEN}Created symlink: $link -> $target${NC}"
}

# Remove all previously created symlinks
cleanup_symlinks() {
    if [[ ! -f "$SYMLINKS_FILE" ]]; then
        echo -e "${BLUE}No previous symlinks to remove${NC}"
        return
    fi
    
    echo -e "${BLUE}Removing previous symlinks...${NC}"
    while IFS= read -r symlink; do
        if [[ -L "$symlink" ]]; then
            rm "$symlink"
            echo -e "${GREEN}Removed: $symlink${NC}"
        elif [[ -e "$symlink" ]]; then
            echo -e "${YELLOW}Warning: $symlink exists but is not a symlink, skipping${NC}"
        fi
    done < "$SYMLINKS_FILE"
    
    rm "$SYMLINKS_FILE"
    echo -e "${GREEN}Cleanup complete${NC}"
}

# Process files in a directory recursively
process_directory() {
    local base_dir=$1
    local current_host=$2
    
    if [[ ! -d "$base_dir" ]]; then
        return
    fi
    
    find "$base_dir" -type f -o -type l | while IFS= read -r file; do
        # Get relative path from base_dir
        local rel_path="${file#$base_dir/}"
        echo "$rel_path"
    done
}

# Main function
main() {
    echo -e "${BLUE}=== Dotfiles Symlink Setup ===${NC}\n"
    
    # Detect host
    CURRENT_HOST=$(detect_host)
    HOST_DIR="$REPO_ROOT/$CURRENT_HOST"
    echo -e "${GREEN}Detected host: $CURRENT_HOST${NC}\n"
    
    # Step 1: Cleanup previous symlinks
    echo -e "${BLUE}Step 1: Cleanup${NC}"
    cleanup_symlinks
    echo ""
    
    # Initialize empty symlinks file
    touch "$SYMLINKS_FILE"
    
    # Create ~/.osconfig if it doesn't exist
    mkdir -p "$HOME/.osconfig"
    
    # Create empty directory if it doesn't exist
    mkdir -p "$EMPTY_DIR"
    
    # Step 2: Process shared files
    echo -e "${BLUE}Step 2: Processing shared files${NC}"
    if [[ -d "$SHARED_DIR" ]]; then
        process_directory "$SHARED_DIR" "$CURRENT_HOST" | while IFS= read -r rel_path; do
            local shared_file="$SHARED_DIR/$rel_path"
            local home_link="$HOME/$rel_path"
            create_symlink "$shared_file" "$home_link"
        done
    else
        echo -e "${YELLOW}Warning: $SHARED_DIR does not exist${NC}"
    fi
    echo ""
    
    # Step 3: Process current host files
    echo -e "${BLUE}Step 3: Processing $CURRENT_HOST files${NC}"
    if [[ -d "$HOST_DIR" ]]; then
        process_directory "$HOST_DIR" "$CURRENT_HOST" | while IFS= read -r rel_path; do
            local host_file="$HOST_DIR/$rel_path"
            local shared_file="$SHARED_DIR/$rel_path"
            
            if [[ -e "$shared_file" || -L "$shared_file" ]]; then
                # File exists in shared, this is a host-specific override
                local osconfig_link="$HOME/.osconfig/$rel_path"
                create_symlink "$host_file" "$osconfig_link"
            else
                # File is unique to this host
                local home_link="$HOME/$rel_path"
                create_symlink "$host_file" "$home_link"
            fi
        done
    else
        echo -e "${YELLOW}Warning: $HOST_DIR does not exist${NC}"
    fi
    echo ""
    
    # Step 4: Process other hosts (create empty files where needed)
    echo -e "${BLUE}Step 4: Processing other hosts (empty file generation)${NC}"
    for other_host in $(get_other_hosts "$CURRENT_HOST"); do
        local other_host_dir="$REPO_ROOT/$other_host"
        
        if [[ ! -d "$other_host_dir" ]]; then
            continue
        fi
        
        process_directory "$other_host_dir" "$CURRENT_HOST" | while IFS= read -r rel_path; do
            local other_host_file="$other_host_dir/$rel_path"
            local shared_file="$SHARED_DIR/$rel_path"
            local current_host_file="$HOST_DIR/$rel_path"
            
            # Check if file exists in shared AND other host, but NOT in current host
            if [[ (-e "$shared_file" || -L "$shared_file") && ! (-e "$current_host_file" || -L "$current_host_file") ]]; then
                # Create empty file and symlink to it
                local empty_file="$EMPTY_DIR/$rel_path"
                local empty_file_dir=$(dirname "$empty_file")
                
                if [[ ! -d "$empty_file_dir" ]]; then
                    mkdir -p "$empty_file_dir"
                fi
                
                if [[ ! -e "$empty_file" ]]; then
                    touch "$empty_file"
                    echo -e "${BLUE}Created empty file: $empty_file${NC}"
                fi
                
                local osconfig_link="$HOME/.osconfig/$rel_path"
                create_symlink "$empty_file" "$osconfig_link"
            fi
        done
    done
    echo ""
    
    echo -e "${GREEN}=== Setup complete! ===${NC}"
    echo -e "${BLUE}Symlinks created: $(wc -l < "$SYMLINKS_FILE")${NC}"
}

main "$@"
