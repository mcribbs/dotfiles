#!/usr/bin/env bash
set -euo pipefail

# Only run inside WSL
if ! grep -qi microsoft /proc/version; then
  exit 0
fi

WIN_USERPROFILE="$(powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("UserProfile")' | tr -d '\r')"
WIN_SSH_DIR="$(wslpath -u "$WIN_USERPROFILE")/.ssh"

mkdir -p "$WIN_SSH_DIR"

for file in config known_hosts github-dotfiles.pub home-admin.pub; do
  if [ -f "$HOME/.ssh/$file" ]; then
    cp "$HOME/.ssh/$file" "$WIN_SSH_DIR/$file"
  fi
done
