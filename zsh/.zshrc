# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


### ENV
# zmodload zsh/zprof

#eval "$(sheldon source)"

# ## Set path for pyenv
# export PYENV_ROOT="${HOME}/.pyenv"
# if [ -d "${PYENV_ROOT}" ]; then
#     eval "$(pyenv init - --no-rehash)"
# fi

ZSHRC_DIR=${${(%):-%N}:A:h}
# source command override technique
function source {
  ensure_zcompiled $1
  builtin source "$@"
}
function ensure_zcompiled {
  local compiled="$1.zwc"
  local real="${1:A}"
  if [[ ! -r "$compiled" || "$real" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}
ensure_zcompiled ~/.zshrc
source $ZSHRC_DIR/configure_variable.zsh
source $ZSHRC_DIR/aliases.zsh

# Skip p10k SSH detection (avoids forking `who` on local sessions)
if [[ -z $SSH_CLIENT && -z $SSH_TTY && -z $SSH_CONNECTION ]]; then
  typeset -gix P9K_SSH=0
  typeset -gx _P9K_SSH_TTY=$TTY
fi

# mise (dev tool version manager) — must be before sheldon/direnv so shims are in PATH
if (( $+commands[mise] )); then
  eval "$(mise activate zsh --shims)"
fi

# sheldon cache technique
if (( $+commands[sheldon] )); then
    export SHELDON_CONFIG_DIR="$ZSHRC_DIR/sheldon"
    sheldon_cache="$SHELDON_CONFIG_DIR/sheldon.zsh"
    sheldon_toml="$SHELDON_CONFIG_DIR/plugins.toml"
    if [[ ! -r "$sheldon_cache" || "$sheldon_toml" -nt "$sheldon_cache" ]]; then
      sheldon source > $sheldon_cache
    fi
    source "$sheldon_cache"
    unset sheldon_cache sheldon_toml
fi

# direnv cache
if (( $+commands[direnv] )); then
    direnv_cache="$HOME/.zsh/cache/direnv.zsh"
    if [ ! -e "$direnv_cache" ]; then
      direnv hook zsh > $direnv_cache
    fi
    source "$direnv_cache"
    unset direnv_cache
fi

[[ -f "$ZSHRC_DIR/nonlazy.zsh" ]] && source "$ZSHRC_DIR/nonlazy.zsh"
[[ -f "$ZSHRC_DIR/lazy.zsh" ]] && zsh-defer source "$ZSHRC_DIR/lazy.zsh"
zsh-defer unfunction source

if (( $+commands[oc] )); then
  _oc_cache="$HOME/.zsh/cache/oc-completion.zsh"
  if [[ ! -r "$_oc_cache" ]]; then
    oc completion zsh > "$_oc_cache"
  fi
  zsh-defer source "$_oc_cache"
  zsh-defer -c 'compdef _oc oc'
  unset _oc_cache
fi

### Google Cloud SDK (gcloud)
# Put SDK somewhere stable (recommended): ~/.local/google-cloud-sdk など
# SDK path is centralized here:
GCLOUD_SDK_DIR="$HOME/.local/google-cloud-sdk"
# もしまだ Downloads にあるなら一旦はこうでもOK:
# GCLOUD_SDK_DIR="$HOME/Downloads/google-cloud-sdk"

if [[ -f "$GCLOUD_SDK_DIR/path.zsh.inc" ]]; then
  source "$GCLOUD_SDK_DIR/path.zsh.inc"
fi

if [[ -f "$GCLOUD_SDK_DIR/completion.zsh.inc" ]]; then
  zsh-defer source "$GCLOUD_SDK_DIR/completion.zsh.inc"
fi
