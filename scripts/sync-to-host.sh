#!/usr/bin/env bash

set -euo pipefail

# Cleanup function for temp files
cleanup() {
    local exit_code=$?
    # Remove temp file if it exists
    [[ -f "$TEMP_SYMLINKS_FILE" ]] && rm -f "$TEMP_SYMLINKS_FILE"
    exit $exit_code
}
trap cleanup EXIT INT TERM

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Statistics tracking
shared_files_count=0
host_files_count=0
symlinks_created=0
symlinks_updated=0
symlinks_unchanged=0
backups_created=0
orphans_removed=0
empty_files_created=0
directories_created=0
empty_dirs_removed=0

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
        directories_created=$((directories_created + 1))
        echo -e "${BLUE}+ Created directory: $link_dir${NC}"
    fi
    
    # Handle existing files/directories
    if [[ -L "$link" ]]; then
        # Already a symlink - check if it points to the correct target
        local current_target=$(readlink "$link")
        if [[ "$current_target" == "$target" ]]; then
            # Correct symlink already exists
            symlinks_unchanged=$((symlinks_unchanged + 1))
            return
        else
            # Symlink points to wrong target, remove and recreate
            rm "$link"
            symlinks_updated=$((symlinks_updated + 1))
            echo -e "${YELLOW}↻ Updated symlink: ${link#$HOME/}${NC}"
        fi
    elif [[ -e "$link" ]]; then
        # Existing file or directory, backup it
        local backup="$link.BAK"
        mv "$link" "$backup"
        backups_created=$((backups_created + 1))
        echo -e "${YELLOW}💾 Backed up: ${link#$HOME/} -> ${backup#$HOME/}${NC}"
    fi
    
    # Create symlink if needed (not already correct)
    if [[ ! -L "$link" ]] || [[ "$(readlink "$link")" != "$target" ]]; then
        ln -s "$target" "$link"
        if [[ $symlinks_updated -eq 0 && $backups_created -eq 0 ]]; then
            symlinks_created=$((symlinks_created + 1))
            echo -e "${GREEN}+ Added: ${link#$HOME/}${NC}"
        fi
    fi
}

# Remove orphaned symlinks (in old list but not in desired list)
cleanup_orphaned_symlinks() {
    if [[ ! -f "$SYMLINKS_FILE" ]]; then
        return
    fi
    
    if [[ ! -f "$TEMP_SYMLINKS_FILE" ]]; then
        return
    fi
    
    # Check each old symlink
    while IFS= read -r symlink; do
        # Check if symlink is in desired set using grep (bash 3.2 compatible)
        if ! grep -Fxq "$symlink" "$TEMP_SYMLINKS_FILE" 2>/dev/null; then
            if [[ -L "$symlink" ]]; then
                rm "$symlink"
                orphans_removed=$((orphans_removed + 1))
                echo -e "${RED}- Removed: ${symlink#$HOME/}${NC}"
                # Clean up empty parent directories
                cleanup_empty_parents "$symlink"
            elif [[ -e "$symlink" ]]; then
                echo -e "${YELLOW}⚠  Warning: ${symlink#$HOME/} exists but is not a symlink, skipping${NC}"
            fi
        fi
    done < "$SYMLINKS_FILE"
    
    rm "$SYMLINKS_FILE"
}

# Clean up empty parent directories after removing a file/symlink
cleanup_empty_parents() {
    local path="$1"
    
    # Get parent directory
    local parent_dir=$(dirname "$path")
    
    # Stop if we've reached HOME or root
    while [[ "$parent_dir" != "$HOME" ]] && [[ "$parent_dir" != "/" ]] && [[ -n "$parent_dir" ]]; do
        # Check if directory is empty (including hidden files)
        if [[ -d "$parent_dir" ]] && [[ -z "$(ls -A "$parent_dir" 2>/dev/null)" ]]; then
            # Directory is empty, remove it
            rmdir "$parent_dir" 2>/dev/null
            if [[ $? -eq 0 ]]; then
                empty_dirs_removed=$((empty_dirs_removed + 1))
                echo -e "${BLUE}🗑  Cleaned up empty directory: ${parent_dir#$HOME/}${NC}"
                # Move up to parent's parent
                parent_dir=$(dirname "$parent_dir")
            else
                # Couldn't remove directory (not empty or permission issue), stop
                break
            fi
        else
            # Directory is not empty, stop
            break
        fi
    done
}

# Process files in a directory recursively
process_directory() {
    local base_dir=$1
    local current_host=$2
    
    if [[ ! -d "$base_dir" ]]; then
        return
    fi
    
    # Write to temp file to avoid pipeline issues
    local temp_file=$(mktemp)
    find "$base_dir" \( -type f -o -type l \) > "$temp_file"
    while IFS= read -r file; do
        # Get relative path from base_dir
        local rel_path="${file#$base_dir/}"
        echo "$rel_path"
    done < "$temp_file"
    rm -f "$temp_file"
}

# Print summary of operations
print_summary() {
    echo -e "\n${BLUE}=== Summary ===${NC}"
    
    # Files processed
    echo -e "${GREEN}Files processed:${NC}"
    echo -e "  Shared: $shared_files_count"
    echo -e "  Host-specific: $host_files_count"
    
    # Symlink operations  
    echo -e "${GREEN}Symlink operations:${NC}"
    echo -e "  Created: $symlinks_created"
    echo -e "  Updated: $symlinks_updated"
    echo -e "  Unchanged: $symlinks_unchanged"
    
    # Cleanup operations
    if [[ $orphans_removed -gt 0 ]] || [[ $empty_dirs_removed -gt 0 ]]; then
        echo -e "${GREEN}Cleanup operations:${NC}"
        [[ $orphans_removed -gt 0 ]] && echo -e "  Orphaned symlinks removed: $orphans_removed"
        [[ $empty_dirs_removed -gt 0 ]] && echo -e "  Empty directories removed: $empty_dirs_removed"
    fi
    
    # Other operations
    if [[ $backups_created -gt 0 ]] || [[ $empty_files_created -gt 0 ]] || [[ $directories_created -gt 0 ]]; then
        echo -e "${GREEN}Other operations:${NC}"
        [[ $backups_created -gt 0 ]] && echo -e "  Backups created: $backups_created"
        [[ $empty_files_created -gt 0 ]] && echo -e "  Empty files created: $empty_files_created"
        [[ $directories_created -gt 0 ]] && echo -e "  Directories created: $directories_created"
    fi
    
    # Total symlinks
    if [[ -f "$SYMLINKS_FILE" ]]; then
        local total_symlinks=$(wc -l < "$SYMLINKS_FILE" 2>/dev/null || echo "0")
        echo -e "${GREEN}Total symlinks managed: $total_symlinks${NC}"
    fi
}

# Print usage information
print_usage() {
    echo "Usage: $(basename "$0") [OPTIONS]"
    echo
    echo "Sync dotfiles to current host by creating symlinks."
    echo
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -q, --quiet    Suppress summary output (still shows changes)"
    echo
    echo "By default, shows only changes (additions, updates, removals) and a summary."
}

# Main function
main() {
    local quiet_mode=0
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                print_usage
                exit 0
                ;;
            -q|--quiet)
                quiet_mode=1
                shift
                ;;
            *)
                echo "Error: Unknown option $1" >&2
                print_usage >&2
                exit 1
                ;;
        esac
    done
    
    if [[ $quiet_mode -eq 0 ]]; then
        echo -e "${BLUE}=== Dotfiles Symlink Setup ===${NC}\n"
    fi
    
    # Detect host
    CURRENT_HOST=$(detect_host)
    HOST_DIR="$REPO_ROOT/$CURRENT_HOST"
    
    if [[ $quiet_mode -eq 0 ]]; then
        echo -e "${GREEN}Detected host: $CURRENT_HOST${NC}\n"
    fi
    
    # Initialize temp symlinks file
    > "$TEMP_SYMLINKS_FILE"
    
    # Create empty directory if it doesn't exist
    mkdir -p "$EMPTY_DIR"
    
    # Step 1: Process shared files
    if [[ $quiet_mode -eq 0 ]]; then
        echo -e "${BLUE}Step 1: Processing shared files${NC}"
    fi
    if [[ -d "$SHARED_DIR" ]]; then
        # Use a temporary file to avoid pipeline subshell issues in zsh
        local temp_file=$(mktemp)
        process_directory "$SHARED_DIR" "$CURRENT_HOST" > "$temp_file"
        while IFS= read -r rel_path; do
            local shared_file="$SHARED_DIR/$rel_path"
            local home_link="$HOME/$rel_path"
            shared_files_count=$((shared_files_count + 1))
            create_symlink "$shared_file" "$home_link"
        done < "$temp_file"
        rm -f "$temp_file"
    else
        echo -e "${YELLOW}Warning: $SHARED_DIR does not exist${NC}"
    fi
    echo ""
    
    # Step 2: Process current host files
    if [[ $quiet_mode -eq 0 ]]; then
        echo -e "${BLUE}Step 2: Processing $CURRENT_HOST files${NC}"
    fi
    if [[ -d "$HOST_DIR" ]]; then
        # Use a temporary file to avoid pipeline subshell issues in zsh
        local temp_file=$(mktemp)
        process_directory "$HOST_DIR" "$CURRENT_HOST" > "$temp_file"
        while IFS= read -r rel_path; do
            local host_file="$HOST_DIR/$rel_path"
            local shared_file="$SHARED_DIR/$rel_path"
            host_files_count=$((host_files_count + 1))
            
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
                : "$local_rel_path"  # Suppress any accidental output
                create_symlink "$host_file" "$home_link"
            else
                # File is unique to this host
                local home_link="$HOME/$rel_path"
                create_symlink "$host_file" "$home_link"
            fi
        done < "$temp_file"
        rm -f "$temp_file"
    else
        echo -e "${YELLOW}Warning: $HOST_DIR does not exist${NC}"
    fi
    echo ""
    
    # Step 3: Process other hosts (create empty files where needed)
    if [[ $quiet_mode -eq 0 ]]; then
        echo -e "${BLUE}Step 3: Processing other hosts (empty file generation)${NC}"
    fi
    for other_host in $(get_other_hosts "$CURRENT_HOST"); do
        local other_host_dir="$REPO_ROOT/$other_host"
        
        if [[ ! -d "$other_host_dir" ]]; then
            continue
        fi
        
        # Use a temporary file to avoid pipeline subshell issues in zsh
        local temp_file=$(mktemp)
        process_directory "$other_host_dir" "$CURRENT_HOST" > "$temp_file"
        while IFS= read -r rel_path; do
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
                        empty_files_created=$((empty_files_created + 1))
                    echo -e "${BLUE}📄 Created empty file: ${empty_file#$REPO_ROOT/}${NC}"
                fi
                
                local home_link="$HOME/$local_rel_path"
                : "$local_rel_path"  # Suppress any accidental output
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
                    empty_files_created=$((empty_files_created + 1))
                        echo -e "${BLUE}📄 Created empty file: ${empty_file#$REPO_ROOT/}${NC}"
                    fi
                    
                    local home_link="$HOME/$rel_path"
                    create_symlink "$empty_file" "$home_link"
                fi
            fi
        done < "$temp_file"
        rm -f "$temp_file"
    done
    echo ""
    
    # Step 4: Remove orphaned symlinks
    if [[ $quiet_mode -eq 0 ]]; then
        echo -e "${BLUE}Step 4: Cleanup${NC}"
    fi
    cleanup_orphaned_symlinks
    if [[ $quiet_mode -eq 0 ]]; then
        echo ""
    fi
    
    # Replace old symlinks file with new one
    mv "$TEMP_SYMLINKS_FILE" "$SYMLINKS_FILE"
    
    # Print summary
    if [[ $quiet_mode -eq 0 ]]; then
        print_summary
        echo -e "${GREEN}✓ Setup complete${NC}"
    fi

    # Reload Hyprland config if on arch
    if [[ "$CURRENT_HOST" == "arch" ]]; then
        if command -v hyprctl >/dev/null 2>&1; then
            echo -e "${YELLOW}Reloading Hyprland config...${NC}"
            hyprctl reload
        fi
    fi
}

main "$@"
