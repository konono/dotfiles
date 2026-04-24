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
  builtin source $1
}
function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}
ensure_zcompiled ~/.zshrc
source $ZSHRC_DIR/configure_variable.zsh
source $ZSHRC_DIR/aliases.zsh

# sheldon cache technique
if type "sheldon" > /dev/null 2>&1; then
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
if type "direnv" > /dev/null 2>&1; then
    direnv_cache="$HOME/.zsh/cache/direnv.zsh"
    if [ ! -e "$direnv_cache" ]; then
      direnv hook zsh > $direnv_cache
    fi
    source "$direnv_cache"
    unset direnv_cache
fi

# fnm (Fast Node Manager)
if type "fnm" > /dev/null 2>&1; then
  eval "$(fnm env)"
fi

[[ -f "$ZSHRC_DIR/nonlazy.zsh" ]] && source "$ZSHRC_DIR/nonlazy.zsh"
[[ -f "$ZSHRC_DIR/lazy.zsh" ]] && zsh-defer source "$ZSHRC_DIR/lazy.zsh"
zsh-defer unfunction source

if [ $commands[oc] ]; then
  builtin source <(oc completion zsh)
  compdef _oc oc
fi

### Rust (cargo)
if [[ -f "$HOME/.cargo/env" ]]; then
  source "$HOME/.cargo/env"
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
  source "$GCLOUD_SDK_DIR/completion.zsh.inc"
fi

# To customize prompt, run `p10k configure` or edit ~/gitrepo/bootstrap/zsh/.p10k.zsh.
[[ ! -f ~/gitrepo/bootstrap/zsh/.p10k.zsh ]] || source ~/gitrepo/bootstrap/zsh/.p10k.zsh
