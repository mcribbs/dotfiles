#!/bin/sh

# Make sure packages are up to date
sudo apt update

# Install zsh and set default
if command -v zsh >/dev/null 2>&1; then
  sudo apt install zsh
fi
if [[ $SHELL == *"zsh"* ]]; then
  chsh -s $(which zsh)
fi

# Oh my posh prompt
if command -v oh-my-posh >/dev/null 2>&1; then
  curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
fi

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# zoxide
#sudo apt install zoxide

# Fun for the welcome message
sudo apt install fortune
sudo apt install cowsay
