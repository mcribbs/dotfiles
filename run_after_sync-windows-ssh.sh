#!/usr/bin/env bash
set -euo pipefail

# Only run inside WSL
if [[ -z "${WSL_DISTRO_NAME:-}" ]]; then
  exit 0
fi

echo "Synching ssh files"

WIN_USERPROFILE="$(powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("UserProfile")' | tr -d '\r')"
WIN_SSH_DIR="$(wslpath -u "$WIN_USERPROFILE")/.ssh"

mkdir -p "$WIN_SSH_DIR"

# Windows SSH owns known_hosts; never overwrite its learned host keys.
for file in config github-dotfiles.pub home-admin.pub; do
  if [ -f "$HOME/.ssh/$file" ]; then
    cp "$HOME/.ssh/$file" "$WIN_SSH_DIR/$file"
  fi
done
