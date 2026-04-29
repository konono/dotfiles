#!/bin/bash
set -euo pipefail

# ============================================================
# Migrate dotfiles from ~/gitrepo/dotfiles to ghq-managed path
# One-time migration script
# ============================================================

OLD_DIR="$HOME/gitrepo/dotfiles"
NEW_DIR="$HOME/ghq/github.com/konono/dotfiles"

if [[ ! -d "$OLD_DIR" ]]; then
  echo "ERROR: $OLD_DIR does not exist"
  exit 1
fi

if [[ -d "$NEW_DIR" ]]; then
  echo "ERROR: $NEW_DIR already exists"
  exit 1
fi

# Check for uncommitted changes
if ! git -C "$OLD_DIR" diff --quiet || ! git -C "$OLD_DIR" diff --cached --quiet; then
  echo "ERROR: Uncommitted changes in $OLD_DIR"
  echo "Commit or stash changes first, then re-run this script."
  exit 1
fi

# ------------------------------------------------------------
# 1. Install ghq
# ------------------------------------------------------------
if ! command -v ghq &>/dev/null; then
  echo "Installing ghq..."
  brew install ghq
fi

# ------------------------------------------------------------
# 2. Move repository
# ------------------------------------------------------------
echo "Moving $OLD_DIR -> $NEW_DIR"
mkdir -p "$(dirname "$NEW_DIR")"
mv "$OLD_DIR" "$NEW_DIR"

# ------------------------------------------------------------
# 3. Update symlinks
# ------------------------------------------------------------
echo "Updating symlinks..."

ln -sf "$NEW_DIR/zsh/.zshrc" ~/.zshrc
ln -sf "$NEW_DIR/tmux/.tmux.conf" ~/.tmux.conf
ln -sfn "$NEW_DIR/nvim" ~/.config/nvim

# Remove stale sheldon symlink (no longer needed)
rm -f ~/.config/sheldon/plugins.toml
rmdir ~/.config/sheldon 2>/dev/null || true

# ------------------------------------------------------------
# 4. Update iTerm2 preferences
# ------------------------------------------------------------
echo "Updating iTerm2 preferences..."
defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$NEW_DIR/iTerm2"

echo ""
echo "Migration complete."
echo "  Old: $OLD_DIR (removed)"
echo "  New: $NEW_DIR"
echo ""
echo "Run: exec zsh"
