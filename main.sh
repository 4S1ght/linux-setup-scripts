#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1

echo "🔑 Requesting sudo access..."
sudo -v || { echo "❌ This script requires sudo privileges."; exit 1; }

# Keep sudo alive
while true; do sudo -n true; sleep 60; done 2>/dev/null &
SUDO_PID=$!
trap 'kill $SUDO_PID' EXIT

# === Subscripts in manual order ===
SCRIPTS=(
    "./scripts/01-system-setup.sh"
    "./scripts/02-flatpak-setup.sh"
)

for script in "${SCRIPTS[@]}"; do
    if [ -x "$script" ]; then
        echo "🚀 Running $script"
        sudo "$script"
        echo "✅ Finished $script"
    else
        echo "⚠️ Skipping $script (not found or not executable)"
    fi
done

echo "🎉 All setup scripts completed successfully."
