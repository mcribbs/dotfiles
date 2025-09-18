#!/usr/bin/env bash
set -euo pipefail
ARCH=$(uname -m)

echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
echo "Setting up environment!"
echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"

echo "Updating apt package lists..."
sudo apt update

echo "Install zsh and set default"
# zsh
if ! command -v zsh >/dev/null 2>&1; then
  echo "Installing zsh..."
  sudo apt install -y zsh
else
  echo "✅ zsh already installed"
fi
# Set zsh as default shell
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "Setting zsh as default shell"
  chsh -s "$(command -v zsh)"
else
  echo "✅ zsh already set as default shell"
fi

# Oh My Posh
if ! command -v unzip >/dev/null 2>&1; then
  echo "Installing unzip..."
  sudo apt install -y unzip
fi
if ! command -v oh-my-posh >/dev/null 2>&1; then
  echo "Installing Oh My Posh..."
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
else
  echo "✅ Oh My Posh already installed"
fi

# fzf
if ! command -v git >/dev/null 2>&1; then
  echo "Installing git..."
  sudo apt install -y git
fi
if [ ! -d "$HOME/.fzf" ]; then
  echo "Installing fzf..."
  git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
  "$HOME/.fzf/install" --all
else
  echo "✅ fzf already installed"
fi

# zoxide
if ! command -v zoxide >/dev/null 2>&1; then
  echo "Installing zoxide..."
  curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
else
  echo "✅ zoxide already installed"
fi

# zellij
if ! command -v zellij >/dev/null 2>&1; then
  echo "Installing zellij..."
  
else
  echo "✅ zellij already installed"
fi

# Welcome apps
# figlet/toilet
if ! command -v figlet >/dev/null 2>&1; then
  echo "Installing figlet..."
  sudo apt install -y figlet
else
  echo "✅ figlet already installed"
fi
if ! command -v toilet >/dev/null 2>&1; then
  echo "Installing toilet..."
  sudo apt install -y toilet
else
  echo "✅ toilet already installed"
fi

#fastfetch
if ! command -v fastfetch >/dev/null 2>&1; then
  echo "Installing fastfetch..."
  if [ "$ARCH" = "x86_64" ]; then
    curl -sLO https://github.com/fastfetch-cli/fastfetch/releases/download/2.52.0/fastfetch-linux-amd64.deb && sudo apt install ./fastfetch-linux-amd64.deb && rm -f ./fastfetch-linux-amd64.deb
  elif [ "$ARCH = "aarch64 ] || [ "$ARCH" = "arm64" ]; then
    curl -sLO https://github.com/fastfetch-cli/fastfetch/releases/download/2.52.0/fastfetch-linux-aarch64.deb && sudo apt install ./fastfetch-linux-aarch64.deb && rm -f ./fastfetch-linux-aarch64.deb
  else
    echo "ERROR: unsupported architecture: $ARCH"
  fi
else
  echo "✅ fastfetch already installed"
fi


echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
echo "Initial setup complete!"
echo "Don't forget to source ~/.zshrc"
echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
