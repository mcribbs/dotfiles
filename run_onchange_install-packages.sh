#!/usr/bin/env bash
set -euo pipefail

echo "Updating package lists..."
sudo apt update

echo "Install zsh and set default"
# Install zsh if not installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "Installing zsh..."
  sudo apt install -y zsh
else
  echo "zsh already installed"
fi
# Set zsh as default shell if not already
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "Setting zsh as default shell"
  chsh -s "$(command -v zsh)"
else
  echo "zsh already set as default shell"
fi

# Install Oh My Posh if not installed
if ! command -v oh-my-posh >/dev/null 2>&1; then
  echo "Installing Oh My Posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
else
  echo "Oh My Posh already installed"
fi

# Install fzf if not installed
if [ ! -d "$HOME/.fzf" ]; then
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all
else
  echo "fzf already installed"
fi

# Install zoxide if not installed
if ! command -v zoxide >/dev/null 2>&1; then
  echo "Installing zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
  echo "zoxide already installed"
fi

# Install fortune and cowsay if not installed
if ! command -v fortune >/dev/null 2>&1; then
  echo "Installing fortune..."
  sudo apt install -y fortune
else
  echo "fortune already installed"
fi
if ! command -v cowsay >/dev/null 2>&1; then
  echo "Installing cowsay..."
  sudo apt install -y cowsay
else
  echo "cowsay already installed"
fi

exec "$(command -v zsh)"
