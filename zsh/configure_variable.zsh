### ------------------------------------------------------------
### Environment / Paths (refactored)
### ------------------------------------------------------------

# Guard (optional): 2重読み込み防止
[[ -n "${ZSH_ENV_LOADED:-}" ]] && return
export ZSH_ENV_LOADED="1"

# Locale / Editor
export LANG="en_US.UTF-8"
export EDITOR="vim"
export SHELL="/bin/zsh"
export CASE_SENSITIVE="true"

# ------------------------------------------------------------
# Prefixes / Base dirs
# ------------------------------------------------------------
# Homebrew prefix (Apple Silicon = /opt/homebrew)
# Intel Mac でも使うなら、必要に応じて /usr/local に切替
BREW_PREFIX="/opt/homebrew"

# User-local bins
LOCAL_BIN="$HOME/.local/bin"
USER_BIN="$HOME/bin"

# ------------------------------------------------------------
# PATH management (zsh way)
# - export PATH=... を連打せず、path 配列で整理
# - 追加は「前に入れる / 後ろに入れる」を明確に
# ------------------------------------------------------------
typeset -U path  # 重複排除（順序は最初に現れたもの優先）
path=(
  "$BREW_PREFIX/bin"
  "$BREW_PREFIX/sbin"
  "$BREW_PREFIX/opt/coreutils/libexec/gnubin"

  # Apps / Tools
  "/Applications/CopyQ.app/Contents/MacOS"

  # User bins
  "/usr/local/bin"            # まだ使ってるなら残す（要らなければ削除）
  "$LOCAL_BIN"
  "$USER_BIN"

  # Language toolchains
  "$HOME/.cargo/bin"
  "$HOME/.codon/bin"

  # (Android platform-tools) ※元の指定はパスが怪しかったので一般的な置き方に寄せる
  "$HOME/.local/bin/platform-tools"

  $path
)
export PATH

# ------------------------------------------------------------
# Man/Info paths（必要な人だけ）
# ※ /usr/local と .linuxbrew は環境次第なので、存在チェック
# ------------------------------------------------------------
[[ -d "/usr/local/man" ]] && export MANPATH="/usr/local/man:${MANPATH:-}"
[[ -d "$HOME/.linuxbrew/share/man" ]] && export MANPATH="$HOME/.linuxbrew/share/man:${MANPATH:-}"
[[ -d "$HOME/.linuxbrew/share/info" ]] && export INFOPATH="$HOME/.linuxbrew/share/info:${INFOPATH:-}"

# ------------------------------------------------------------
# dircolors (GNU coreutils) — gdircolors があるときだけ
# ------------------------------------------------------------
if (( $+commands[gdircolors] )) && [[ -f "$HOME/.dirc" ]]; then
  _gdircolors_cache="$HOME/.zsh/cache/gdircolors.zsh"
  if [[ ! -r "$_gdircolors_cache" || "$HOME/.dirc" -nt "$_gdircolors_cache" ]]; then
    gdircolors -b "$HOME/.dirc" > "$_gdircolors_cache"
  fi
  builtin source "$_gdircolors_cache"
  unset _gdircolors_cache
fi


# ------------------------------------------------------------
# FZF / ripgrep
# ------------------------------------------------------------
export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git"'
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'

# ------------------------------------------------------------
# History
# ------------------------------------------------------------
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000000

# ------------------------------------------------------------
# Go
# ------------------------------------------------------------
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
path=("$GOBIN" $path)
export PATH

# ------------------------------------------------------------
# Podman / Docker socket（パス間違いがありそうだったので修正）
# 元: $HOME.local/... は多分 $HOME/.local/... のつもり
# ------------------------------------------------------------
export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/qemu/podman.sock"

# ------------------------------------------------------------
# pipenv
# ------------------------------------------------------------
export PIPENV_VENV_IN_PROJECT=1

# ------------------------------------------------------------
# Vagrant
# ------------------------------------------------------------
export VAGRANT_EXPERIMENTAL="typed_triggers"

# ------------------------------------------------------------
# Powerlevel9k/10k
# ------------------------------------------------------------
export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=false

# ------------------------------------------------------------
# macOS fork safety workaround（必要な時だけ使うのが基本）
# 何かobjc forkエラーが出るなら有効化、出ないならコメントアウト推奨
# ------------------------------------------------------------
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES


# ------------------------------------------------------------
# GCP with Claudeの設定
# ------------------------------------------------------------
export GCP_PROJECT_ID=REDACTED_GCP_PROJECT_ID
export CLAUDE_CODE_USE_VERTEX=1
export CLOUD_ML_REGION=us-east5
export ANTHROPIC_VERTEX_PROJECT_ID=$GCP_PROJECT_ID


# ------------------------------------------------------------
# Ruby gems bin（固定バージョンは壊れやすいので、必要なら動的に）
# 例: gem env で拾う / rbenv の shims に任せる方が安全
# ------------------------------------------------------------
# if (( $+commands[ruby] )); then
#   GEM_BIN="$(ruby -e 'print Gem.user_dir')/bin"
#   [[ -d "$GEM_BIN" ]] && path=("$GEM_BIN" $path)
#   export PATH
# fi
