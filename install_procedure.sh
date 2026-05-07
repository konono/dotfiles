#!/bin/bash
set -euo pipefail

# ============================================================
# dotfiles setup script
# ============================================================

# ------------------------------------------------------------
# 1. Homebrew
# ------------------------------------------------------------
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ------------------------------------------------------------
# 2. ghq + dotfiles
# ------------------------------------------------------------
brew install ghq
ghq get konono/dotfiles
DOTFILES_DIR="$(ghq root)/github.com/konono/dotfiles"
echo "dotfiles directory: $DOTFILES_DIR"

# ------------------------------------------------------------
# 3. Homebrew packages (Brewfile)
# ------------------------------------------------------------
echo "Installing Homebrew packages..."
brew bundle install --file="$DOTFILES_DIR/Brewfile"

# ------------------------------------------------------------
# 4. GitHub CLI authentication
# ------------------------------------------------------------
echo "Setting up GitHub CLI..."
if ! gh auth status &>/dev/null; then
  echo "gh is not authenticated. Running gh auth login..."
  gh auth login
fi
export GITHUB_TOKEN="$(gh auth token 2>/dev/null)"

# ------------------------------------------------------------
# 5. mise (tool version manager)
# ------------------------------------------------------------
echo "Setting up mise..."
mkdir -p ~/.config/mise
ln -sf "$DOTFILES_DIR/mise/config.toml" ~/.config/mise/config.toml
eval "$(mise activate bash --shims)"
mise install --yes

# ------------------------------------------------------------
# 6. Symlinks
# ------------------------------------------------------------
echo "Creating symlinks..."
mkdir -p ~/.config

# Home directory
ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES_DIR/dirc/.dirc" ~/.dirc
ln -sfn "$DOTFILES_DIR/vim" ~/.vim

# ~/.config directories
ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/peco/.config/peco" ~/.config/peco
ln -sfn "$DOTFILES_DIR/yazi" ~/.config/yazi
ln -sfn "$DOTFILES_DIR/zellij" ~/.config/zellij
ln -sfn "$DOTFILES_DIR/ghostty" ~/Library/Application\ Support/com.mitchellh.ghostty

# copyq (individual files)
mkdir -p ~/.config/copyq
for f in "$DOTFILES_DIR"/copyq/.config/copyq/*.ini; do
  ln -sf "$f" ~/.config/copyq/"$(basename "$f")"
done

# ------------------------------------------------------------
# 7. zellij plugins
# ------------------------------------------------------------
echo "Downloading zellij plugins..."
mkdir -p ~/.config/zellij/plugins
if [[ ! -f ~/.config/zellij/plugins/zjstatus.wasm ]]; then
  curl -fsSL -o ~/.config/zellij/plugins/zjstatus.wasm \
    "$(gh api repos/dj95/zjstatus/releases/latest --jq '.assets[] | select(.name == "zjstatus.wasm") | .browser_download_url')"
fi

# ------------------------------------------------------------
# 8. Python + pynvim (for neovim)
# ------------------------------------------------------------
echo "Setting up Python for neovim..."
uv venv ~/.config/nvim/venv --python "$(mise where python)/bin/python3"
uv pip install --python ~/.config/nvim/venv/bin/python pynvim

# ------------------------------------------------------------
# 9. uv tools (Python CLI tools)
# ------------------------------------------------------------
echo "Installing Python CLI tools via uv..."
uv tool install awscli
uv tool install awxkit --with "setuptools<70"
uv tool install workday-calc

# ------------------------------------------------------------
# 10. sheldon plugins
# ------------------------------------------------------------
echo "Setting up sheldon plugins..."
SHELDON_CONFIG_DIR="$DOTFILES_DIR/zsh/sheldon" sheldon lock

# ------------------------------------------------------------
# 11. iTerm2
# ------------------------------------------------------------
echo "Configuring iTerm2..."
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iTerm2"

# ------------------------------------------------------------
# 12. Cache directories
# ------------------------------------------------------------
mkdir -p ~/.zsh/cache

echo "Done. Restart your shell: exec zsh"
