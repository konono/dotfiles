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

# direnv cache 
if type "direnv" > /dev/null 2>&1; then
    direnv_cache="$HOME/.zsh/cache/direnv.zsh"
    if [ ! -e "$direnv_cache" ]; then
      direnv hook zsh > $direnv_cache
    fi
    source "$direnv_cache"
    unset direnv_cache
fi

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

source $ZSHRC_DIR/nonlazy.zsh
zsh-defer source $ZSHRC_DIR/lazy.zsh
if type "rye" > /dev/null 2>&1; then
    zsh-defer source "$HOME/.rye/env"
fi
zsh-defer unfunction source
