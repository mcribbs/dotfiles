#!/usr/bin/env bash
set -euo pipefail
ARCH=$(uname -m)
OS=$(uname -s)

ensure_local_bin() {
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
}

install_homebrew_if_missing() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found — installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for this script run (supports Apple Silicon and Intel)
    if [ -d "/opt/homebrew/bin" ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -d "/usr/local/bin" ]; then
      export PATH="/usr/local/bin:$PATH"
    fi
  else
    echo "✅ Homebrew already installed"
  fi
}

apt_update_if_needed() {
  if command -v apt >/dev/null 2>&1; then
    echo "Updating apt package lists..."
    sudo apt update
  fi
}

install_system_package() {
  local pkg="$1"
  if [ "$OS" = "Darwin" ]; then
    brew install "$pkg"
  else
    sudo apt install -y "$pkg"
  fi
}

ensure_tool() {
  local cmd="$1"
  local pkg="${2:-$1}"

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "✅ $cmd already installed"
    return 0
  fi

  echo "Installing $cmd..."
  install_system_package "$pkg"
}

echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
echo "Setting up environment!"
echo "Detected OS: $OS  ARCH: $ARCH"
echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"

ensure_local_bin
if [ "$OS" = "Darwin" ]; then
  echo "Running macOS (Homebrew) path"
  install_homebrew_if_missing
  brew update || true
else
  echo "Running Linux (apt) path"
  apt_update_if_needed
fi

ensure_tool zsh
if [[ "$SHELL" != *"zsh"* ]]; then
  echo "Setting zsh as default shell"
  chsh -s "$(command -v zsh)" || true
else
  echo "✅ zsh already set as default shell"
fi

ensure_tool unzip

if command -v oh-my-posh >/dev/null 2>&1; then
  echo "✅ oh-my-posh already installed"
else
  echo "Installing oh-my-posh..."
  if [ "$OS" = "Darwin" ]; then
    brew install jandedobbeleer/oh-my-posh/oh-my-posh || brew install oh-my-posh
  else
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/.local/bin"
  fi
fi

ensure_tool git

if [ -d "$HOME/.fzf" ] || command -v fzf >/dev/null 2>&1; then
  echo "✅ fzf already installed"
else
  echo "Installing fzf..."
  if [ "$OS" = "Darwin" ]; then
    brew install fzf
    brew_prefix="$(brew --prefix)"
    if [ -f "$brew_prefix/opt/fzf/install" ]; then
      "$brew_prefix/opt/fzf/install" --all || true
    fi
  else
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --all || true
  fi
fi

if command -v zoxide >/dev/null 2>&1; then
  echo "✅ zoxide already installed"
else
  echo "Installing zoxide..."
  if [ "$OS" = "Darwin" ]; then
    install_system_package zoxide
  else
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
  fi
fi

if command -v zellij >/dev/null 2>&1; then
  echo "✅ zellij already installed"
else
  echo "Installing zellij..."
  if [ "$OS" = "Darwin" ]; then
    install_system_package zellij
  else
    if [ "$ARCH" = "x86_64" ]; then
      archive="zellij-x86_64-unknown-linux-musl.tar.gz"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
      archive="zellij-aarch64-unknown-linux-musl.tar.gz"
    else
      echo "ERROR: unsupported architecture: $ARCH"
      archive=""
    fi

    if [ -n "${archive:-}" ]; then
      curl -sLO "https://github.com/zellij-org/zellij/releases/download/v0.43.1/${archive}"
      tar -xvf "./${archive}"
      rm -f "./${archive}"
      chmod +x ./zellij || true
      mv ./zellij "$HOME/.local/bin/" || true
    fi
  fi
fi

ensure_tool toilet
font_dir="$HOME/.config/figlet"
font_path="$font_dir/Ivrit.flf"
if [ -f "$font_path" ]; then
  echo "✅ Ivrit figlet font already downloaded"
else
  echo "Downloading Ivrit figlet font..."
  mkdir -p "$font_dir"
  curl -fsSL "https://raw.githubusercontent.com/xero/figlet-fonts/refs/heads/master/Ivrit.flf" -o "$font_path"
fi

if command -v fastfetch >/dev/null 2>&1; then
  echo "✅ fastfetch already installed"
else
  echo "Installing fastfetch..."
  if [ "$OS" = "Darwin" ]; then
    install_system_package fastfetch || true
  else
    if [ "$ARCH" = "x86_64" ]; then
      deb="fastfetch-linux-amd64.deb"
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
      deb="fastfetch-linux-aarch64.deb"
    else
      echo "ERROR: unsupported architecture: $ARCH"
      deb=""
    fi

    if [ -n "${deb:-}" ]; then
      curl -sLO "https://github.com/fastfetch-cli/fastfetch/releases/download/2.52.0/${deb}"
      sudo apt install -y "./${deb}"
      rm -f "./${deb}"
    fi
  fi
fi


echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
echo "Initial setup complete!"
echo "Don't forget to source ~/.zshrc"
echo "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
