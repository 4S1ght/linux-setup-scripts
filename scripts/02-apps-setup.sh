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
    ["EasyEffects"]="com.github.wwmm.easyeffects"
    ["Signal Messenger"]="org.signal.Signal"
    ["GIMP"]="org.gimp.GIMP"
)

# Collect apps to install
to_flatpak=()
install_vscode=false
install_git=false
install_nvm=false
install_nodejs=false

echo "📌 Select apps/tools to install (press y/n):"

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

# Git
while true; do
    read -n1 -rp "Do you want to install Git? [y/n]: " yn
    echo
    case $yn in
        [Yy]) install_git=true; break;;
        [Nn]) break;;
        *) echo "Please press y or n.";;
    esac
done

# NVM (+ optional Node.js latest)
while true; do
    read -n1 -rp "Do you want to install NVM (Node Version Manager)? [y/n]: " yn
    echo
    case $yn in
        [Yy]) install_nvm=true; break;;
        [Nn]) break;;
        *) echo "Please press y or n.";;
    esac
done

if $install_nvm; then
    while true; do
        read -n1 -rp "Do you also want to install the latest Node.js via NVM? [y/n]: " yn
        echo
        case $yn in
            [Yy]) install_nodejs=true; break;;
            [Nn]) break;;
            *) echo "Please press y or n.";;
        esac
    done
fi

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
    sudo dnf check-update || true
    sudo dnf install -y code
fi

# === Install Git ===
if $install_git; then
    echo
    echo "🔧 Installing Git..."
    sudo dnf install -y git
fi

# === Install NVM ===
if $install_nvm; then
    echo
    echo "📥 Installing NVM..."
    
    export NVM_DIR="$HOME/.nvm"

    # Run official NVM install script if missing
    if [ ! -d "$NVM_DIR" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/refs/heads/master/install.sh | bash
    fi

    # Load NVM for current script
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
    fi
    if [ -s "$NVM_DIR/bash_completion" ]; then
        \. "$NVM_DIR/bash_completion"
    fi

    # Optional Node.js install
    if $install_nodejs; then
        echo
        echo "🌐 Installing latest Node.js with NVM..."
        nvm install --lts
        nvm alias default 'lts/*'
    fi
fi



echo
echo "🎉 All selected apps and tools installed successfully."
