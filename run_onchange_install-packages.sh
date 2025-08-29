#!/bin/sh
curl -s https://ohmyposh.dev/install.sh | bash -s
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
sudo apt install zoxide
sudo apt install fortune
sudo apt install cowsay
