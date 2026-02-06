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
TEMP_SYMLINKS_FILE="$REPO_ROOT/.symlinks.tmp"

# Extract base filename from a path (e.g., .zshrc.env -> .zshrc)
# Returns empty string if the file doesn't have a dot-separated suffix
get_base_filename() {
    local filepath=$1
    local filename=$(basename "$filepath")
    local dirname=$(dirname "$filepath")
    
    # Check if filename has a pattern like "basename.suffix"
    # We need at least one dot that's not at the start
    if [[ "$filename" =~ ^(.+)\.([^.]+)$ ]]; then
        local base="${BASH_REMATCH[1]}"
        local suffix="${BASH_REMATCH[2]}"
        
        # Don't treat .local as a regular suffix - it's reserved for overrides
        if [[ "$suffix" == "local" ]]; then
            echo ""
        else
            # Return the full path with just the base filename
            if [[ "$dirname" == "." ]]; then
                echo "$base"
            else
                echo "$dirname/$base"
            fi
        fi
    else
        echo ""
    fi
}

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
    
    # Always record in temp file
    echo "$link" >> "$TEMP_SYMLINKS_FILE"
    
    # Create parent directory if it doesn't exist
    local link_dir=$(dirname "$link")
    if [[ ! -d "$link_dir" ]]; then
        mkdir -p "$link_dir"
        echo -e "${BLUE}Created directory: $link_dir${NC}"
    fi
    
    # Handle existing files/directories
    if [[ -L "$link" ]]; then
        # Already a symlink - check if it points to the correct target
        local current_target=$(readlink "$link")
        if [[ "$current_target" == "$target" ]]; then
            # Correct symlink already exists
            echo -e "${BLUE}Symlink already exists: $link -> $target${NC}"
            return
        else
            # Symlink points to wrong target, remove and recreate
            rm "$link"
            echo -e "${YELLOW}Updated symlink: $link${NC}"
            echo -e "${YELLOW}  Old: $current_target${NC}"
            echo -e "${YELLOW}  New: $target${NC}"
        fi
    elif [[ -e "$link" ]]; then
        # Existing file or directory, backup it
        local backup="$link.BAK"
        mv "$link" "$backup"
        echo -e "${YELLOW}Backed up existing file: $link -> $backup${NC}"
    fi
    
    # Create symlink
    ln -s "$target" "$link"
    echo -e "${GREEN}Created symlink: $link -> $target${NC}"
}

# Remove orphaned symlinks (in old list but not in desired list)
cleanup_orphaned_symlinks() {
    if [[ ! -f "$SYMLINKS_FILE" ]]; then
        echo -e "${BLUE}No previous symlinks file found${NC}"
        return
    fi
    
    if [[ ! -f "$TEMP_SYMLINKS_FILE" ]]; then
        echo -e "${YELLOW}Warning: No desired symlinks collected${NC}"
        return
    fi
    
    echo -e "${BLUE}Checking for orphaned symlinks...${NC}"
    
    # Create associative array of desired symlinks for fast lookup
    declare -A desired_set
    while IFS= read -r symlink; do
        desired_set["$symlink"]=1
    done < "$TEMP_SYMLINKS_FILE"
    
    local removed_count=0
    
    # Check each old symlink
    while IFS= read -r symlink; do
        # If not in desired set, remove it
        if [[ ! -v desired_set["$symlink"] ]]; then
            if [[ -L "$symlink" ]]; then
                rm "$symlink"
                echo -e "${YELLOW}Removed orphaned symlink: $symlink${NC}"
                ((removed_count++))
            elif [[ -e "$symlink" ]]; then
                echo -e "${YELLOW}Warning: $symlink exists but is not a symlink, skipping${NC}"
            fi
        fi
    done < "$SYMLINKS_FILE"
    
    if [[ $removed_count -eq 0 ]]; then
        echo -e "${BLUE}No orphaned symlinks found${NC}"
    else
        echo -e "${GREEN}Removed $removed_count orphaned symlink(s)${NC}"
    fi
    
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
    
    # Initialize temp symlinks file
    > "$TEMP_SYMLINKS_FILE"
    
    # Create empty directory if it doesn't exist
    mkdir -p "$EMPTY_DIR"
    
    # Step 1: Process shared files
    echo -e "${BLUE}Step 1: Processing shared files${NC}"
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
    
    # Step 2: Process current host files
    echo -e "${BLUE}Step 2: Processing $CURRENT_HOST files${NC}"
    if [[ -d "$HOST_DIR" ]]; then
        process_directory "$HOST_DIR" "$CURRENT_HOST" | while IFS= read -r rel_path; do
            local host_file="$HOST_DIR/$rel_path"
            local shared_file="$SHARED_DIR/$rel_path"
            
            if [[ -e "$shared_file" || -L "$shared_file" ]]; then
                # File exists in shared, this is a host-specific override
                # Append .local to the filename
                local dir=$(dirname "$rel_path")
                local filename=$(basename "$rel_path")
                local local_rel_path
                if [[ "$dir" == "." ]]; then
                    local_rel_path="${filename}.local"
                else
                    local_rel_path="${dir}/${filename}.local"
                fi
                local home_link="$HOME/$local_rel_path"
                create_symlink "$host_file" "$home_link"
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
    
    # Step 3: Process other hosts (create empty files where needed)
    echo -e "${BLUE}Step 3: Processing other hosts (empty file generation)${NC}"
    for other_host in $(get_other_hosts "$CURRENT_HOST"); do
        local other_host_dir="$REPO_ROOT/$other_host"
        
        if [[ ! -d "$other_host_dir" ]]; then
            continue
        fi
        
        process_directory "$other_host_dir" "$CURRENT_HOST" | while IFS= read -r rel_path; do
            local other_host_file="$other_host_dir/$rel_path"
            local shared_file="$SHARED_DIR/$rel_path"
            local current_host_file="$HOST_DIR/$rel_path"
            
            # Case 1: File exists in shared AND other host, but NOT in current host
            # Create empty .local override
            if [[ (-e "$shared_file" || -L "$shared_file") && ! (-e "$current_host_file" || -L "$current_host_file") ]]; then
                local dir=$(dirname "$rel_path")
                local filename=$(basename "$rel_path")
                local local_rel_path
                if [[ "$dir" == "." ]]; then
                    local_rel_path="${filename}.local"
                else
                    local_rel_path="${dir}/${filename}.local"
                fi
                
                local empty_file="$EMPTY_DIR/$local_rel_path"
                local empty_file_dir=$(dirname "$empty_file")
                
                if [[ ! -d "$empty_file_dir" ]]; then
                    mkdir -p "$empty_file_dir"
                fi
                
                if [[ ! -e "$empty_file" ]]; then
                    touch "$empty_file"
                    echo -e "${BLUE}Created empty file: $empty_file${NC}"
                fi
                
                local home_link="$HOME/$local_rel_path"
                create_symlink "$empty_file" "$home_link"
            fi
            
            # Case 2: Check if this is an additional file (baseFileName.suffix pattern)
            # and if the base file exists in shared or current host
            local base_rel_path=$(get_base_filename "$rel_path")
            if [[ -n "$base_rel_path" ]]; then
                local base_shared_file="$SHARED_DIR/$base_rel_path"
                local base_current_host_file="$HOST_DIR/$base_rel_path"
                
                # If base file exists in shared or current host, but this suffix file doesn't exist in current host
                if [[ ((-e "$base_shared_file" || -L "$base_shared_file") || (-e "$base_current_host_file" || -L "$base_current_host_file")) && ! (-e "$current_host_file" || -L "$current_host_file") ]]; then
                    local empty_file="$EMPTY_DIR/$rel_path"
                    local empty_file_dir=$(dirname "$empty_file")
                    
                    if [[ ! -d "$empty_file_dir" ]]; then
                        mkdir -p "$empty_file_dir"
                    fi
                    
                    if [[ ! -e "$empty_file" ]]; then
                        touch "$empty_file"
                        echo -e "${BLUE}Created empty file: $empty_file${NC}"
                    fi
                    
                    local home_link="$HOME/$rel_path"
                    create_symlink "$empty_file" "$home_link"
                fi
            fi
        done
    done
    echo ""
    
    # Step 4: Remove orphaned symlinks
    echo -e "${BLUE}Step 4: Cleanup${NC}"
    cleanup_orphaned_symlinks
    echo ""
    
    # Replace old symlinks file with new one
    mv "$TEMP_SYMLINKS_FILE" "$SYMLINKS_FILE"
    
    echo -e "${GREEN}=== Setup complete! ===${NC}"
    echo -e "${BLUE}Total symlinks: $(wc -l < "$SYMLINKS_FILE")${NC}"

    # Reload Hyprland config if on arch
    if [[ "$CURRENT_HOST" == "arch" ]]; then
        if command -v hyprctl >/dev/null 2>&1; then
            echo -e "${YELLOW}Reloading Hyprland config...${NC}"
            hyprctl reload
        fi
    fi
}

main "$@"
