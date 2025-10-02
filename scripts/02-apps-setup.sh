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

# === Define apps ===
declare -A flatpak_apps=(
    ["Brave Browser"]="com.brave.Browser"
    ["Zen Browser"]="app.zen_browser.zen"
    ["Discord"]="com.discordapp.Discord"
    ["Blender"]="org.blender.Blender"
    ["EasyEffects"]="com.github.wwmm.easyeffects",
    ["Signal Messenger"]="org.signal.Signal"
    ["GIMP"]="org.gimp.GIMP"
)

# Collect apps to install
to_flatpak=()
install_vscode=false

echo "📌 Select apps to install (press y/n):"

# Flatpak apps
for name in "${!flatpak_apps[@]}"; do
    while true; do
        read -n1 -rp "Do you want to install $name? [y/n]: " yn
        echo
        case $yn in
            [Yy]) to_flatpak+=("${flatpak_apps[$name]}"); break;;
            [Nn]) break;;
            *) echo "Please press y or n.";;
        esac
    done
done

# VSCode (special DNF setup)
while true; do
    read -n1 -rp "Do you want to install Visual Studio Code? [y/n]: " yn
    echo
    case $yn in
        [Yy]) install_vscode=true; break;;
        [Nn]) break;;
        *) echo "Please press y or n.";;
    esac
done

# === Install Flatpak apps ===
if [ ${#to_flatpak[@]} -gt 0 ]; then
    echo
    echo "🚀 Installing selected Flatpak apps..."
    for pkg in "${to_flatpak[@]}"; do
        echo "🌿 Installing $pkg..."
        flatpak install -y flathub "$pkg"
    done
fi

# === Install VSCode via DNF ===
if $install_vscode; then
    echo
    echo "💻 Installing Visual Studio Code..."
    
    # Import Microsoft GPG key
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    
    # Add VSCode repo
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" \
        | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null

    # Refresh repos and install
    sudo dnf check-update
    sudo dnf install -y code
fi

echo
echo "🎉 All selected apps installed successfully."