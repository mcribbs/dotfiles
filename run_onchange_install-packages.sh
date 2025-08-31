#!/bin/sh

echo "Make sure packages are up to date"
sudo apt update

echo "Install zsh and set default"
if command -v zsh >/dev/null 2>&1; then
  sudo apt install zsh
else 
  echo "zsh already installed"
fi
if [[ $SHELL == *"zsh"* ]]; then
  echo "setting zsh as default"
  chsh -s $(which zsh)
else
  echo "zsh already default"
fi

# Oh my posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
else
  echo "Oh my posh already installed"
fi

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# zoxide
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Fun for the welcome message
sudo apt install fortune
sudo apt install cowsay
