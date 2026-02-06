# macOS Migration Checklist

This checklist guides you through safely migrating your macOS machine to the new dotfiles setup.

## ✅ Pre-Migration Completed

The following preparations have been completed:

- [x] Created [macos/Brewfile](macos/Brewfile) with all required packages
- [x] Created [shared/PACKAGES.md](shared/PACKAGES.md) documentation
- [x] Updated [shared/.gitconfig](shared/.gitconfig) to use environment variables
- [x] Created [shared/.config/env/env.local.example](shared/.config/env/env.local.example) template
- [x] Created [macos/.config/kitty/kitty.conf.local](macos/.config/kitty/kitty.conf.local) with font and Nerd Font mappings
- [x] Created [macos/.zshrc.local](macos/.zshrc.local) with DHIS2 aliases and utilities
- [x] Fixed opencode path in [shared/.zshrc](shared/.zshrc) to use `$HOME`
- [x] Verified [macos/.zshrc.env](macos/.zshrc.env) - ANTIDOTE_DIR is correct

## 📋 Pre-Flight Safety Checks

### 1. Manual Backup (CRITICAL)

Before running the sync script, backup your current configs:

```bash
# Create timestamped backup directory
BACKUP_DIR=~/dotfiles-backup-$(date +%Y%m%d-%H%M%S)
mkdir -p "$BACKUP_DIR"

# Backup critical configs
cp -r ~/.zshrc "$BACKUP_DIR/"
cp -r ~/.gitconfig "$BACKUP_DIR/"
cp -r ~/.tmux.conf "$BACKUP_DIR/" 2>/dev/null || true
cp -r ~/.config/kitty "$BACKUP_DIR/kitty" 2>/dev/null || true
cp -r ~/.config/nvim "$BACKUP_DIR/nvim" 2>/dev/null || true
cp -r ~/.config/starship "$BACKUP_DIR/starship" 2>/dev/null || true
cp -r ~/.zsh_env_vars "$BACKUP_DIR/" 2>/dev/null || true
cp -r ~/.config/env/env.local "$BACKUP_DIR/env.local" 2>/dev/null || true

echo "✓ Backup created: $BACKUP_DIR"
ls -la "$BACKUP_DIR"
```

### 2. Create Environment Variables File

The new setup uses `~/.config/env/env.local` for secrets and machine-specific config:

```bash
# Create directory
mkdir -p ~/.config/env

# Copy template
cp ~/Apps/dotfiles/shared/.config/env/env.local.example ~/.config/env/env.local

# Edit with your values
nvim ~/.config/env/env.local
```

**Required values to set:**
- `GIT_USER_EMAIL` - Your work email: `hendrik@dhis2.org`
- `GPG_SIGNING_KEY` - Your GPG key: `F8B9AA805289DCA3226D7A3CD1AEFD7E58C3F967`

**Optional values (copy from your backup):**
- `GITHUB_API_KEY` (from `~/.config/env/env.local`)
- `DEEPSEEK_API_KEY` (from `~/.config/env/env.local`)
- `OPENAI_API_BASE` and `OPENAI_API_KEY` (from `~/.zsh_env_vars`)

### 3. Verify Repository State

```bash
cd ~/Apps/dotfiles

# Confirm you're on the right branch
git status
git branch

# Review what will be synced
echo "=== Files in shared/ ==="
ls -la shared/
echo "=== Files in macos/ ==="
ls -la macos/
```

### 4. Check Package Installation

Check which packages are already installed vs what's needed:

```bash
# Save a list of currently installed packages
brew list > ~/brew-before-migration.txt

# Check key packages
echo "Checking required packages..."
command -v antidote && echo "✓ antidote" || echo "✗ antidote - NEED TO INSTALL"
command -v starship && echo "✓ starship" || echo "✗ starship - NEED TO INSTALL"
command -v zoxide && echo "✓ zoxide" || echo "✗ zoxide - NEED TO INSTALL"
command -v delta && echo "✓ delta" || echo "✗ delta - NEED TO INSTALL"
command -v bat && echo "✓ bat" || echo "✗ bat - NEED TO INSTALL"
command -v lazygit && echo "✓ lazygit" || echo "✗ lazygit - NEED TO INSTALL"
command -v gitmux && echo "✓ gitmux" || echo "✗ gitmux - NEED TO INSTALL"
test -d ~/.tmux/plugins/tpm && echo "✓ TPM" || echo "✗ TPM - NEED TO INSTALL"
```

## 🚀 Migration Steps

### Step 1: Install Missing Packages

```bash
cd ~/Apps/dotfiles

# Install all required packages
brew bundle install --file=macos/Brewfile

# Install TPM (Tmux Plugin Manager) if not present
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "✓ TPM installed"
fi
```

### Step 2: Install Bat Theme

```bash
# Create themes directory
mkdir -p "$(bat --config-dir)/themes"

# Download Catppuccin Mocha theme
curl -o "$(bat --config-dir)/themes/Catppuccin Mocha.tmTheme" \
  https://raw.githubusercontent.com/catppuccin/bat/main/themes/Catppuccin%20Mocha.tmTheme

# Build cache
bat cache --build

echo "✓ Bat theme installed"
```

### Step 3: Run Sync Script

⚠️ **WARNING:** This will move your current config files to `.BAK` and create symlinks.

```bash
cd ~/Apps/dotfiles

# Review what the script does (optional - read the script)
cat scripts/sync-to-host.sh

# Run the sync script
./scripts/sync-to-host.sh
```

The script will:
- Detect macOS and use `shared/` + `macos/` configs
- Move existing files to `.BAK` (e.g., `~/.zshrc` → `~/.zshrc.BAK`)
- Create symlinks: `~/.zshrc` → `~/Apps/dotfiles/shared/.zshrc`
- Create host-specific symlinks: `~/.zshrc.local` → `~/Apps/dotfiles/macos/.zshrc.local`

### Step 4: Verify Symlinks

```bash
# Check symlinks in home directory
echo "=== Symlinks in ~ ==="
ls -la ~ | grep '\->'

# Check symlinks in .config
echo "=== Symlinks in ~/.config ==="
ls -la ~/.config | grep '\->'

# Check backup files
echo "=== Backup files ==="
ls -la ~ | grep '\.BAK$'
```

## ✓ Post-Migration Verification

### 1. Test Shell Startup

```bash
# Test in a new shell (should load without errors)
zsh -l

# Check that antidote loaded
antidote list

# Verify starship
starship --version

# Check zoxide
zoxide --version
```

### 2. Verify Git Configuration

```bash
# Check email is loaded from env var
git config user.email
# Should show: hendrik@dhis2.org

# Check signing key
git config user.signingkey
# Should show: F8B9AA805289DCA3226D7A3CD1AEFD7E58C3F967

# Test git diff (should use delta)
cd ~/Apps/dotfiles
git diff
```

### 3. Test Kitty

```bash
# Launch kitty (should show Catppuccin theme, size 16, proper symbols)
# Check that Nerd Font icons display correctly in:
kitty

# Inside kitty, test:
starship preset nerd-font-symbols
```

### 4. Test Tmux

```bash
# Start tmux
tmux

# Install plugins: Press Ctrl+a then Shift+I
# Wait for installation to complete
# Should see Catppuccin theme and gitmux status
```

### 5. Test Neovim

```bash
# Launch neovim
nvim

# LazyVim should load
# Check :checkhealth for any issues
```

### 6. Test Aliases

```bash
# Test zoxide
z Apps  # Should cd to ~/Apps

# Test custom aliases
alias | grep saw
alias | grep docker
alias | grep dhis2

# Test that DHIS2_HOME is set
echo $DHIS2_HOME
# Should show: /Users/hendrik/.config/dhis2_home
```

## 🔧 Troubleshooting

### Shell startup errors

```bash
# Test zsh with debugging
zsh -x

# Check which file has the error
source ~/.zshrc
```

### Antidote not loading

```bash
# Verify ANTIDOTE_DIR
echo $ANTIDOTE_DIR
# Should be: /opt/homebrew/share/antidote

# Check if antidote exists
ls -la $ANTIDOTE_DIR/antidote.zsh
```

### Git commands don't use delta

```bash
# Check git config
git config --list | grep pager
git config --list | grep delta

# Verify delta is installed
which delta
delta --version
```

### Kitty symbols not showing

```bash
# Check font installation
fc-list | grep -i cascadia

# Debug font fallback
kitty --debug-font-fallback
```

## 🔄 Rollback (if needed)

If something goes wrong:

```bash
# Remove symlinks
rm ~/.zshrc ~/.gitconfig ~/.tmux.conf
rm -rf ~/.config/kitty ~/.config/nvim ~/.config/starship

# Restore from .BAK files
cp ~/.zshrc.BAK ~/.zshrc
cp ~/.gitconfig.BAK ~/.gitconfig
cp ~/.tmux.conf.BAK ~/.tmux.conf 2>/dev/null || true
cp -r ~/.config/kitty.BAK ~/.config/kitty 2>/dev/null || true

# Or restore from manual backup
BACKUP_DIR=~/dotfiles-backup-YYYYMMDD-HHMMSS  # Use your actual backup dir
cp -r $BACKUP_DIR/* ~/

echo "✓ Restored from backup"
```

## 📝 Next Steps

After successful migration:

1. **Commit the changes** to your dotfiles repo:
   ```bash
   cd ~/Apps/dotfiles
   git add .
   git commit -m "Add macOS-specific configs and package documentation"
   git push
   ```

2. **Test everything thoroughly** for a few days before cleaning up

3. **Clean up old files** (after confirming everything works):
   ```bash
   # Remove .BAK files
   rm ~/.zshrc.BAK ~/.gitconfig.BAK
   rm -rf ~/.config/kitty.BAK ~/.config/nvim.BAK

   # Remove old oh-my-zsh (if you're happy with antidote)
   rm -rf ~/.oh-my-zsh

   # Remove old env files
   rm ~/.zsh_env_vars
   ```

4. **Update README** with macOS-specific notes if needed

## 📚 Reference

- Package documentation: [shared/PACKAGES.md](shared/PACKAGES.md)
- Environment variables template: [shared/.config/env/env.local.example](shared/.config/env/env.local.example)
- macOS Brewfile: [macos/Brewfile](macos/Brewfile)
- Sync script: [scripts/sync-to-host.sh](scripts/sync-to-host.sh)
