#!/bin/bash
set -euo pipefail

echo "📦 Setting up Flatpak and Flathub..."

# Install Flatpak if missing
dnf -y install flatpak

# Add Flathub repo if not already present
if ! flatpak remote-list | grep -q flathub; then
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
fi

# Optionally update Flatpak apps
flatpak update -y

echo "✅ Flatpak setup complete."
