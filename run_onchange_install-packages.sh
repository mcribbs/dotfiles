#!/usr/bin/env bash
set -Eeuo pipefail

ARCH="$(uname -m)"
OS="$(uname -s)"
PACKAGE_MANAGER=""

trap 'echo "❌ Setup failed near line $LINENO" >&2' ERR

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

ensure_local_bin() {
  mkdir -p "$HOME/.local/bin"
  export PATH="$HOME/.local/bin:$PATH"
}

install_homebrew_if_missing() {
  if ! command -v brew >/dev/null 2>&1; then
    log "Homebrew not found — installing Homebrew..."
    /bin/bash -c \
      "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    log "✅ Homebrew already installed"
  fi

  # Make brew available during this script run.
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

detect_package_manager() {
  case "$OS" in
    Darwin)
      install_homebrew_if_missing
      PACKAGE_MANAGER="brew"
      ;;

    Linux)
      if command -v pacman >/dev/null 2>&1; then
        PACKAGE_MANAGER="pacman"
      elif command -v apt-get >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
      else
        die "No supported package manager found. Supported: pacman, apt, brew."
      fi
      ;;

    *)
      die "Unsupported operating system: $OS"
      ;;
  esac
}

prepare_package_manager() {
  case "$PACKAGE_MANAGER" in
    brew)
      brew update || true
      ;;

    apt)
      log "Updating apt package lists..."
      sudo apt-get update
      ;;

    pacman)
      # Do not run `pacman -Sy`. Arch-based systems do not support
      # partial upgrades.
      #
      # `pacman -S` below uses the currently synchronized database.
      # To request a full upgrade before installing packages:
      #
      #   CHEZMOI_PACMAN_UPGRADE=1 chezmoi apply
      #
      if [[ "${CHEZMOI_PACMAN_UPGRADE:-0}" == "1" ]]; then
        log "Performing full pacman system upgrade..."
        sudo pacman -Syu --noconfirm
      else
        log "Using current pacman database without refreshing it."
      fi
      ;;
  esac
}

install_system_package() {
  local pkg="$1"

  case "$PACKAGE_MANAGER" in
    brew)
      brew install "$pkg"
      ;;

    apt)
      sudo apt-get install -y "$pkg"
      ;;

    pacman)
      sudo pacman -S --needed --noconfirm "$pkg"
      ;;

    *)
      die "Unknown package manager: $PACKAGE_MANAGER"
      ;;
  esac
}

package_name_for() {
  local tool="$1"

  case "$PACKAGE_MANAGER:$tool" in
    brew:fortune)
      printf '%s\n' "fortune"
      ;;

    apt:fortune | pacman:fortune)
      printf '%s\n' "fortune-mod"
      ;;

    *)
      printf '%s\n' "$tool"
      ;;
  esac
}

apt_package_available() {
  local pkg="$1"
  apt-cache show "$pkg" >/dev/null 2>&1
}

install_oh_my_posh() {
  if [[ "$PACKAGE_MANAGER" == "brew" ]]; then
    brew install jandedobbeleer/oh-my-posh/oh-my-posh \
      || brew install oh-my-posh
  else
    curl -fsSL https://ohmyposh.dev/install.sh \
      | bash -s -- -d "$HOME/.local/bin"
  fi
}

install_zellij_binary() {
  local archive
  local tmpdir

  case "$ARCH" in
    x86_64)
      archive="zellij-x86_64-unknown-linux-musl.tar.gz"
      ;;

    aarch64 | arm64)
      archive="zellij-aarch64-unknown-linux-musl.tar.gz"
      ;;

    *)
      die "Unsupported architecture for Zellij binary: $ARCH"
      ;;
  esac

  tmpdir="$(mktemp -d)"

  curl -fL \
    "https://github.com/zellij-org/zellij/releases/latest/download/${archive}" \
    -o "$tmpdir/$archive"

  tar -xzf "$tmpdir/$archive" -C "$tmpdir"
  install -m 0755 "$tmpdir/zellij" "$HOME/.local/bin/zellij"

  rm -rf "$tmpdir"
}

install_fastfetch_deb() {
  local deb_arch
  local deb
  local tmpdir

  case "$ARCH" in
    x86_64)
      deb_arch="amd64"
      ;;

    aarch64 | arm64)
      deb_arch="aarch64"
      ;;

    *)
      die "Unsupported architecture for Fastfetch .deb: $ARCH"
      ;;
  esac

  deb="fastfetch-linux-${deb_arch}.deb"
  tmpdir="$(mktemp -d)"

  curl -fL \
    "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/${deb}" \
    -o "$tmpdir/$deb"

  sudo apt-get install -y "$tmpdir/$deb"

  rm -rf "$tmpdir"
}

install_tool() {
  local tool="$1"
  local pkg

  case "$PACKAGE_MANAGER:$tool" in
    brew:oh-my-posh | apt:oh-my-posh | pacman:oh-my-posh)
      install_oh_my_posh
      ;;

    apt:zellij)
      if apt_package_available zellij; then
        install_system_package zellij
      else
        install_zellij_binary
      fi
      ;;

    apt:fastfetch)
      if apt_package_available fastfetch; then
        install_system_package fastfetch
      else
        install_fastfetch_deb
      fi
      ;;

    *)
      pkg="$(package_name_for "$tool")"
      install_system_package "$pkg"
      ;;
  esac
}

ensure_tool() {
  local cmd="$1"
  local tool="${2:-$1}"

  if command -v "$cmd" >/dev/null 2>&1; then
    log "✅ $cmd already installed"
    return 0
  fi

  log "Installing $cmd..."
  install_tool "$tool"

  command -v "$cmd" >/dev/null 2>&1 \
    || die "$cmd was installed but is still not available on PATH"
}

set_zsh_as_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    log "✅ zsh already set as default shell"
    return 0
  fi

  log "Setting zsh as default shell"
  chsh -s "$zsh_path" || true
}

install_figlet_font() {
  local font_dir="$HOME/.config/figlet"
  local font_path="$font_dir/Ivrit.flf"

  if [[ -f "$font_path" ]]; then
    log "✅ Ivrit figlet font already downloaded"
    return 0
  fi

  log "Downloading Ivrit figlet font..."
  mkdir -p "$font_dir"

  curl -fsSL \
    "https://raw.githubusercontent.com/xero/figlet-fonts/main/Ivrit.flf" \
    -o "$font_path"
}

log "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
log "Setting up environment!"
log "Detected OS: $OS  ARCH: $ARCH"
log "-=-=-=-=-=-=-=-=-=-=-=-=--=-"

ensure_local_bin
detect_package_manager

log "Package manager: $PACKAGE_MANAGER"

prepare_package_manager

# Common package-managed tools.
ensure_tool curl
ensure_tool tar
ensure_tool zsh
ensure_tool unzip
ensure_tool git
ensure_tool rg ripgrep
ensure_tool fzf
ensure_tool zoxide
ensure_tool toilet
ensure_tool fortune fortune

# Tools with package-manager-specific installation strategies.
ensure_tool oh-my-posh oh-my-posh
ensure_tool zellij
ensure_tool fastfetch

set_zsh_as_default_shell
install_figlet_font

log "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
log "Initial setup complete!"
log "Don't forget to source ~/.zshrc"
log "If 1Password is installed, update ~/.config/chezmoi/local.toml"
log "[data]"
log "onepassword_ssh_agent = true"
log "onepassword_ssh_agent_socket = <from 1Password developer mode>"
log "-=-=-=-=-=-=-=-=-=-=-=-=--=-"
