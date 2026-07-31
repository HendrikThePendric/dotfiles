#!/bin/bash
set -e

THEME_NAME="catppuccin-mocha-lavender-standard+default"
THEME_URL="https://github.com/catppuccin/gtk/releases/download/v1.0.3/catppuccin-mocha-lavender-standard%2Bdefault.zip"
PAPIRUS_REPO="https://github.com/catppuccin/papirus-folders.git"
PAPIRUS_SCRIPT="https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders"
COLOR="cat-mocha-lavender"
ICON_THEME="Papirus-Dark"

echo "==> Installing Catppuccin GTK theme..."
mkdir -p "$HOME/.themes"
if [ ! -d "$HOME/.themes/$THEME_NAME" ]; then
    cd /tmp
    wget -q "$THEME_URL" -O catppuccin-gtk.zip
    unzip -oq catppuccin-gtk.zip -d "$HOME/.themes/"
    rm -f catppuccin-gtk.zip
fi

echo "==> Setting up Papirus folder icons..."
mkdir -p "$HOME/.local/share/icons/$ICON_THEME"
if [ ! -d "$HOME/.local/share/icons/$ICON_THEME/64x64" ]; then
    cd /tmp
    rm -rf papirus-folders 2>/dev/null
    git clone --depth 1 "$PAPIRUS_REPO" papirus-folders
    cp -r papirus-folders/src/* "$HOME/.local/share/icons/$ICON_THEME/"
    rm -rf papirus-folders
fi

echo "==> Creating lavender folder symlinks..."
cd "$HOME/.local/share/icons/$ICON_THEME"
for size in 22x22 24x24 32x32 48x48 64x64; do
    [ -d "$size/places" ] || continue
    cd "$size/places"
    for f in folder-cat-mocha-lavender.svg; do
        [ -f "$f" ] && ln -sf "$f" folder.svg
    done
    for f in folder-cat-mocha-lavender-*.svg; do
        [ -f "$f" ] || continue
        target=$(echo "$(basename "$f")" | sed 's/-cat-mocha-lavender//')
        ln -sf "$(basename "$f")" "$target"
    done
    for f in user-cat-mocha-lavender-*.svg; do
        [ -f "$f" ] || continue
        target=$(echo "$(basename "$f")" | sed 's/-cat-mocha-lavender//')
        ln -sf "$(basename "$f")" "$target"
    done
    ln -sf "folder-cat-mocha-lavender-public.svg" folder-publicshare.svg 2>/dev/null || true
    cd - >/dev/null
done

echo "==> Creating icon theme index..."
cat > "$HOME/.local/share/icons/$ICON_THEME/index.theme" << 'THEMEEOF'
[Icon Theme]
Name=Papirus-Dark
Inherits=Papirus
Directories=22x22/places,24x24/places,32x32/places,48x48/places,64x64/places

[22x22/places]
Size=22
Context=Places
Type=Fixed

[24x24/places]
Size=24
Context=Places
Type=Fixed

[32x32/places]
Size=32
Context=Places
Type=Fixed

[48x48/places]
Size=48
Context=Places
Type=Fixed

[64x64/places]
Size=64
Context=Places
Type=Fixed
THEMEEOF

echo "==> Updating icon cache..."
gtk-update-icon-cache -f "$HOME/.local/share/icons/$ICON_THEME/"

echo "==> Applying GTK settings..."
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface gtk-theme "$THEME_NAME" 2>/dev/null || true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' 2>/dev/null || true
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null || true
gsettings set org.cinnamon.desktop.interface icon-theme "$ICON_THEME" 2>/dev/null || true

echo "==> Done. Restart GTK apps to see changes."
