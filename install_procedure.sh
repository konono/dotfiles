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
# 4. uv (Python package manager)
# ------------------------------------------------------------
if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# ------------------------------------------------------------
# 5. Symlinks
# ------------------------------------------------------------
echo "Creating symlinks..."

ln -sf "$DOTFILES_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/tmux/.tmux.conf" ~/.tmux.conf
ln -sf "$DOTFILES_DIR/dirc/.dirc" ~/.dirc

mkdir -p ~/.config
ln -sfn "$DOTFILES_DIR/nvim" ~/.config/nvim
ln -sfn "$DOTFILES_DIR/peco/.config/peco" ~/.config/peco
ln -sfn "$DOTFILES_DIR/vim" ~/.vim

mkdir -p ~/.config/copyq
for f in "$DOTFILES_DIR"/copyq/.config/copyq/*.ini; do
  ln -sf "$f" ~/.config/copyq/"$(basename "$f")"
done

# ------------------------------------------------------------
# 6. Python + pynvim
# ------------------------------------------------------------
echo "Setting up Python for neovim..."
export PATH="$HOME/.local/bin:$PATH"
uv python install
uv pip install --system pynvim

# ------------------------------------------------------------
# 7. sheldon plugins
# ------------------------------------------------------------
echo "Setting up sheldon plugins..."
SHELDON_CONFIG_DIR="$DOTFILES_DIR/zsh/sheldon" sheldon lock

# ------------------------------------------------------------
# 8. iTerm2
# ------------------------------------------------------------
echo "Configuring iTerm2..."
defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$DOTFILES_DIR/iTerm2"

# ------------------------------------------------------------
# 9. Cache directories
# ------------------------------------------------------------
mkdir -p ~/.zsh/cache

echo "Done. Restart your shell: exec zsh"
