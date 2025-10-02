#!/bin/bash
set -euo pipefail

echo "📦 Setting up Flatpak and Flathub..."

# Install Flatpak if missing
if ! command -v flatpak &>/dev/null; then
    echo "🌿 Installing Flatpak..."
    sudo dnf -y install flatpak
fi

# Add Flathub repo if not already present
if ! flatpak remote-list | grep -q flathub; then
    echo "🌐 Adding Flathub remote..."
    sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Optionally update Flatpak apps
echo "🔄 Updating Flatpak apps..."
flatpak update -y

echo "✅ Flatpak setup complete."
echo

# === Interactive app selection ===
declare -A apps=(
    ["Brave Browser"]="com.brave.Browser"
    ["Zen Browser"]="app.zen_browser.zen"
    ["Discord"]="com.discordapp.Discord"
    ["Blender"]="org.blender.Blender"
    ["EasyEffects"]="com.github.wwmm.easyeffects",
    ["Signal Messenger"]="org.signal.Signal"
    ["GIMP"]="org.gimp.GIMP",
    ["VS Code"]="com.visualstudio.code",
)

to_install=()

echo "📌 Select apps to install:"

for name in "${!apps[@]}"; do
    while true; do
        read -n1 -rp "Do you want to install $name? [y/n]: " yn
        echo   # move to a new line after key press
        case $yn in
            [Yy]) to_install+=("${apps[$name]}"); break;;
            [Nn]) break;;
            *) echo "Please press y or n.";;
        esac
    done
done


if [ ${#to_install[@]} -eq 0 ]; then
    echo "⚠️ No apps selected. Skipping installation."
    exit 0
fi

echo
echo "🚀 Installing selected apps..."
for pkg in "${to_install[@]}"; do
    echo "🌿 Installing $pkg..."
    flatpak install -y flathub "$pkg"
done

echo "🎉 Selected apps installed successfully."
