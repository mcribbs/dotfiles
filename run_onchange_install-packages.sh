#!/bin/sh

# Make sure packages are up to date
sudo apt update

# Install zsh and set default
sudo apt install zsh
chsh -s $(which zsh)

# Oh my posh prompt
curl -s https://ohmyposh.dev/install.sh | bash -s -d ~/.local/bin

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# zoxide
#sudo apt install zoxide

# Fun for the welcome message
sudo apt install fortune
sudo apt install cowsay
