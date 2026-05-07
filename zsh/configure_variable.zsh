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
# Platform detection
# ------------------------------------------------------------
case "$(uname -s)" in
  Darwin) _is_macos=1 ;;
  *)      _is_macos=0 ;;
esac

# ------------------------------------------------------------
# Prefixes / Base dirs
# ------------------------------------------------------------
LOCAL_BIN="$HOME/.local/bin"
USER_BIN="$HOME/bin"

# ------------------------------------------------------------
# PATH management (zsh way)
# - export PATH=... を連打せず、path 配列で整理
# - 追加は「前に入れる / 後ろに入れる」を明確に
# ------------------------------------------------------------
typeset -U path  # 重複排除（順序は最初に現れたもの優先）

if (( _is_macos )); then
  BREW_PREFIX="/opt/homebrew"
  path=(
    "$BREW_PREFIX/bin"
    "$BREW_PREFIX/sbin"
    "$BREW_PREFIX/opt/coreutils/libexec/gnubin"
    "/Applications/CopyQ.app/Contents/MacOS"
    "/usr/local/bin"
    "$LOCAL_BIN"
    "$USER_BIN"
    "$HOME/.local/bin/platform-tools"
    $path
  )
else
  path=(
    "/usr/local/bin"
    "$LOCAL_BIN"
    "$USER_BIN"
    $path
  )
fi
export PATH

# ------------------------------------------------------------
# Man/Info paths（必要な人だけ）
# ※ /usr/local と .linuxbrew は環境次第なので、存在チェック
# ------------------------------------------------------------
[[ -d "/usr/local/man" ]] && export MANPATH="/usr/local/man:${MANPATH:-}"
[[ -d "$HOME/.linuxbrew/share/man" ]] && export MANPATH="$HOME/.linuxbrew/share/man:${MANPATH:-}"
[[ -d "$HOME/.linuxbrew/share/info" ]] && export INFOPATH="$HOME/.linuxbrew/share/info:${INFOPATH:-}"

# ------------------------------------------------------------
# dircolors (GNU coreutils)
# macOS: gdircolors (coreutils via Homebrew)
# Linux: dircolors (native)
# ------------------------------------------------------------
if (( _is_macos )); then
  _dircolors_cmd=gdircolors
else
  _dircolors_cmd=dircolors
fi
if (( $+commands[$_dircolors_cmd] )) && [[ -f "$HOME/.dirc" ]]; then
  _dircolors_cache="$HOME/.zsh/cache/dircolors.zsh"
  if [[ ! -r "$_dircolors_cache" || "$HOME/.dirc" -nt "$_dircolors_cache" ]]; then
    $_dircolors_cmd -b "$HOME/.dirc" > "$_dircolors_cache"
  fi
  builtin source "$_dircolors_cache"
  unset _dircolors_cache
fi
unset _dircolors_cmd


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
# Podman / Docker socket
# ------------------------------------------------------------
if (( $+commands[podman] )); then
  if (( _is_macos )); then
    export DOCKER_HOST="unix://$HOME/.local/share/containers/podman/machine/qemu/podman.sock"
  elif [[ -S "/run/user/$(id -u)/podman/podman.sock" ]]; then
    export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"
  fi
fi

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
# macOS fork safety workaround
# ------------------------------------------------------------
if (( _is_macos )); then
  export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
fi


# ------------------------------------------------------------
# GitHub token for mise / API access
# ------------------------------------------------------------
if [[ -z "${GITHUB_TOKEN:-}" ]] && (( $+commands[gh] )); then
  GITHUB_TOKEN="$(gh auth token 2>/dev/null)" && export GITHUB_TOKEN
fi

# ------------------------------------------------------------
# GCP with Claudeの設定 (.env から読み込み)
# ------------------------------------------------------------
_dotfiles_env="${ZSHRC_DIR:h}/.env"
if [[ -f "$_dotfiles_env" ]]; then
  source "$_dotfiles_env"
  export GCP_PROJECT_ID CLAUDE_CODE_USE_VERTEX CLOUD_ML_REGION ANTHROPIC_VERTEX_PROJECT_ID
  export CLAUDE_CODE_USE_VERTEX="${CLAUDE_CODE_USE_VERTEX:-1}"
  export ANTHROPIC_VERTEX_PROJECT_ID="${ANTHROPIC_VERTEX_PROJECT_ID:-$GCP_PROJECT_ID}"
fi
unset _dotfiles_env


# ------------------------------------------------------------
# Ruby gems bin（固定バージョンは壊れやすいので、必要なら動的に）
# 例: gem env で拾う / rbenv の shims に任せる方が安全
# ------------------------------------------------------------
# if (( $+commands[ruby] )); then
#   GEM_BIN="$(ruby -e 'print Gem.user_dir')/bin"
#   [[ -d "$GEM_BIN" ]] && path=("$GEM_BIN" $path)
#   export PATH
# fi
