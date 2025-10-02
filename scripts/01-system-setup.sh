#!/bin/bash
set -euo pipefail

echo "📦 Updating and upgrading system packages..."

# Ensure DNF is up to date
dnf -y upgrade --refresh

# Install essential utilities
dnf -y install \
    curl wget git unzip \
    vim nano htop \
    gcc make

# Enable RPM Fusion (for codecs, proprietary drivers, etc.)
echo "🎶 Enabling RPM Fusion repositories..."
dnf -y install \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Enable Cisco OpenH264 repo
echo "🎥 Enabling Cisco OpenH264 repo..."
dnf config-manager setopt fedora-cisco-openh264.enabled=1

# Install codecs
dnf -y install mozilla-openh264

# Update after repos are added
dnf -y upgrade --refresh

echo "✅ System setup and updates complete."
