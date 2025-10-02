#!/bin/bash
set -euo pipefail

# Ask interactively
read -rp "Enter remote hostname or IP: " REMOTE_HOST
read -rp "Enter remote username: " REMOTE_USER
read -sp "Enter SSH password for $REMOTE_USER@$REMOTE_HOST: " SSH_PASS
echo
read -rp "Enter path on remote (default: /home/$REMOTE_USER/linux-setup-scripts): " REMOTE_DIR

REMOTE_DIR=${REMOTE_DIR:-/home/$REMOTE_USER/linux-setup-scripts}
LOCAL_REPO="$(cd "$(dirname "$0")" && pwd)"

# Check if sshpass is installed
if ! command -v sshpass &>/dev/null; then
    echo "❌ sshpass not found. Install it first (e.g., sudo dnf install sshpass)."
    exit 1
fi

echo "📦 Copying '$LOCAL_REPO' to '$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR' (ignoring .git)..."
sshpass -p "$SSH_PASS" rsync -avz --delete \
    --exclude='.git/' \
    --exclude='.gitignore' \
    "$LOCAL_REPO/" "$REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/"

echo "🔑 Setting execute permission for main.sh on remote..."
sshpass -p "$SSH_PASS" ssh "$REMOTE_USER@$REMOTE_HOST" "chmod +x '$REMOTE_DIR/main.sh'"

echo "🔑 Setting execute permissions for subscripts on remote..."
sshpass -p "$SSH_PASS" ssh "$REMOTE_USER@$REMOTE_HOST" "chmod +x '$REMOTE_DIR/scripts/'*.sh"

echo "🔗 Connecting via SSH and running main.sh..."
sshpass -p "$SSH_PASS" ssh -t "$REMOTE_USER@$REMOTE_HOST" "cd '$REMOTE_DIR' && ./main.sh"
