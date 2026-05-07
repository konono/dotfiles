#!/bin/bash
set -euo pipefail

# ============================================================
# dotfiles setup script for Linux
# OS-family agnostic: supports Debian/Ubuntu, RHEL/Fedora,
# SUSE, Arch, Alpine
# ============================================================

DOTFILES_REPO="https://github.com/konono/dotfiles.git"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/ghq/github.com/konono/dotfiles}"

# ------------------------------------------------------------
# Package manager detection
# ------------------------------------------------------------
detect_pkg_manager() {
  if command -v apt-get &>/dev/null; then echo "apt"
  elif command -v dnf &>/dev/null; then echo "dnf"
  elif command -v yum &>/dev/null; then echo "yum"
  elif command -v zypper &>/dev/null; then echo "zypper"
  elif command -v pacman &>/dev/null; then echo "pacman"
  elif command -v apk &>/dev/null; then echo "apk"
  else echo "unknown"
  fi
}

# ------------------------------------------------------------
# Install bootstrap packages
# ------------------------------------------------------------
install_packages() {
  local pkg_manager="$1"
  shift
  local packages=("$@")

  echo "Installing packages via $pkg_manager: ${packages[*]}"
  case "$pkg_manager" in
    apt)
      sudo apt-get update -qq
      sudo apt-get install -y "${packages[@]}"
      ;;
    dnf)
      sudo dnf install -y "${packages[@]}"
      ;;
    yum)
      sudo yum install -y "${packages[@]}"
      ;;
    zypper)
      sudo zypper install -y "${packages[@]}"
      ;;
    pacman)
      sudo pacman -Sy --noconfirm "${packages[@]}"
      ;;
    apk)
      sudo apk add "${packages[@]}"
      ;;
    *)
      echo "ERROR: Unknown package manager. Install manually: ${packages[*]}"
      exit 1
      ;;
  esac
}

# Map logical package names to distro-specific names
get_bootstrap_packages() {
  local pkg_manager="$1"
  local packages=(git zsh curl tar unzip tmux htop tree)

  case "$pkg_manager" in
    apt)
      packages+=(build-essential)
      ;;
    dnf|yum)
      packages+=(gcc make)
      ;;
    zypper)
      packages+=(gcc make)
      ;;
    pacman)
      packages+=(base-devel)
      ;;
    apk)
      packages+=(build-base)
      ;;
  esac

  # Clipboard support
  if [ -n "${WAYLAND_DISPLAY:-}" ]; then
    case "$pkg_manager" in
      apt)     packages+=(wl-clipboard) ;;
      dnf|yum) packages+=(wl-clipboard) ;;
      zypper)  packages+=(wl-clipboard) ;;
      pacman)  packages+=(wl-clipboard) ;;
      apk)     packages+=(wl-clipboard) ;;
    esac
  elif [ -n "${DISPLAY:-}" ]; then
    case "$pkg_manager" in
      apt)     packages+=(xclip) ;;
      dnf|yum) packages+=(xclip) ;;
      zypper)  packages+=(xclip) ;;
      pacman)  packages+=(xclip) ;;
      apk)     packages+=(xclip) ;;
    esac
  fi

  echo "${packages[@]}"
}

# ------------------------------------------------------------
# 1. Detect OS & install bootstrap packages
# ------------------------------------------------------------
echo "=== Step 1: Bootstrap system packages ==="

PKG_MANAGER=$(detect_pkg_manager)
echo "Detected package manager: $PKG_MANAGER"

BOOTSTRAP_PKGS=($(get_bootstrap_packages "$PKG_MANAGER"))
install_packages "$PKG_MANAGER" "${BOOTSTRAP_PKGS[@]}"

# ------------------------------------------------------------
# 2. Install mise
# ------------------------------------------------------------
echo ""
echo "=== Step 2: Install mise ==="

if ! command -v mise &>/dev/null; then
  curl https://mise.run | sh
  export PATH="$HOME/.local/bin:$PATH"
fi
echo "mise version: $(mise --version)"

# ------------------------------------------------------------
# 3. Clone dotfiles
# ------------------------------------------------------------
echo ""
echo "=== Step 3: Clone dotfiles ==="

if [ -d "$DOTFILES_DIR" ]; then
  echo "dotfiles already exists at $DOTFILES_DIR, pulling latest..."
  git -C "$DOTFILES_DIR" pull --ff-only || true
else
  echo "Cloning dotfiles to $DOTFILES_DIR..."
  mkdir -p "$(dirname "$DOTFILES_DIR")"
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
fi
echo "dotfiles directory: $DOTFILES_DIR"

# ------------------------------------------------------------
# 4. mise setup
# ------------------------------------------------------------
echo ""
echo "=== Step 4: Setup mise ==="

mkdir -p ~/.config/mise
ln -sf "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml
eval "$(mise activate bash --shims)"
mise install --yes

# ------------------------------------------------------------
# 5. Symlinks
# ------------------------------------------------------------
echo ""
echo "=== Step 5: Create symlinks ==="

mkdir -p ~/.config

# Home directory
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/tmux/linux_server/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES_DIR/dirc/.dirc" ~/.dirc
ln -sfn "$DOTFILES_DIR/vim" ~/.vim

# ~/.config directories
ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/peco/.config/peco" ~/.config/peco
ln -sfn "$DOTFILES_DIR/yazi" ~/.config/yazi
ln -sfn "$DOTFILES_DIR/zellij" ~/.config/zellij

echo "Symlinks created."

# ------------------------------------------------------------
# 6. bin/ wrapper scripts
# ------------------------------------------------------------
echo ""
echo "=== Step 6: Install wrapper scripts ==="

mkdir -p ~/.local/bin
for f in "$DOTFILES_DIR"/bin/*; do
  ln -sf "$f" ~/.local/bin/"$(basename "$f")"
done
echo "Wrapper scripts linked to ~/.local/bin/"

# ------------------------------------------------------------
# 7. Zellij plugins
# ------------------------------------------------------------
echo ""
echo "=== Step 7: Download zellij plugins ==="

mkdir -p ~/.config/zellij/plugins
if [[ ! -f ~/.config/zellij/plugins/zjstatus.wasm ]]; then
  if command -v gh &>/dev/null; then
    curl -fsSL -o ~/.config/zellij/plugins/zjstatus.wasm \
      "$(gh api repos/dj95/zjstatus/releases/latest --jq '.assets[] | select(.name == "zjstatus.wasm") | .browser_download_url')"
    echo "zjstatus.wasm downloaded."
  else
    echo "WARNING: gh not found, skipping zjstatus.wasm download."
    echo "  Run 'gh api repos/dj95/zjstatus/releases/latest' after mise install completes."
  fi
else
  echo "zjstatus.wasm already exists, skipping."
fi

# ------------------------------------------------------------
# 8. Python + pynvim
# ------------------------------------------------------------
echo ""
echo "=== Step 8: Setup Python for neovim ==="

if command -v uv &>/dev/null && command -v mise &>/dev/null; then
  uv venv ~/.config/nvim/venv --python "$(mise where python)/bin/python3"
  uv pip install --python ~/.config/nvim/venv/bin/python pynvim
  echo "pynvim installed."
else
  echo "WARNING: uv or mise not ready, skipping pynvim setup."
fi

# ------------------------------------------------------------
# 9. uv tools
# ------------------------------------------------------------
echo ""
echo "=== Step 9: Install Python CLI tools via uv ==="

if command -v uv &>/dev/null; then
  uv tool install awscli || true
  uv tool install awxkit "setuptools<70" || true
  uv tool install workday-calc || true
  echo "Python CLI tools installed."
else
  echo "WARNING: uv not found, skipping Python CLI tools."
fi

# ------------------------------------------------------------
# 10. Sheldon plugins
# ------------------------------------------------------------
echo ""
echo "=== Step 10: Setup sheldon plugins ==="

if command -v sheldon &>/dev/null; then
  SHELDON_CONFIG_DIR="$DOTFILES_DIR/zsh/sheldon" sheldon lock
  echo "sheldon plugins locked."
else
  echo "WARNING: sheldon not found, skipping plugin lock."
fi

# ------------------------------------------------------------
# 11. Cache directories
# ------------------------------------------------------------
echo ""
echo "=== Step 11: Create cache directories ==="

mkdir -p ~/.zsh/cache

# ------------------------------------------------------------
# 12. Default shell
# ------------------------------------------------------------
echo ""
echo "=== Step 12: Set default shell to zsh ==="

ZSH_PATH=$(which zsh)
if [ "$(basename "$SHELL")" != "zsh" ]; then
  if grep -q "$ZSH_PATH" /etc/shells; then
    chsh -s "$ZSH_PATH"
    echo "Default shell changed to $ZSH_PATH"
  else
    echo "WARNING: $ZSH_PATH is not in /etc/shells."
    echo "  Run: sudo sh -c 'echo $ZSH_PATH >> /etc/shells' && chsh -s $ZSH_PATH"
  fi
else
  echo "Default shell is already zsh."
fi

echo ""
echo "=== Done! Restart your shell: exec zsh ==="
