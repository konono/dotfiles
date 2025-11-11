# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
export PATH="/Users/yyamashi/scripts:$PATH"
fpath=(/Users/yyamashi/.zsh/completions $fpath)

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

if [ -d $HOME/.rye ]; then
    zsh-defer source "$HOME/.rye/env"
    unset sheldon_cache sheldon_toml
fi

source $ZSHRC_DIR/nonlazy.zsh
zsh-defer source $ZSHRC_DIR/lazy.zsh
zsh-defer unfunction source

if [ $commands[oc] ]; then
  builtin source <(oc completion zsh)
  compdef _oc oc
fi


# To customize prompt, run `p10k configure` or edit ~/gitrepo/bootstrap/zsh/.p10k.zsh.
[[ ! -f ~/gitrepo/bootstrap/zsh/.p10k.zsh ]] || source ~/gitrepo/bootstrap/zsh/.p10k.zsh

#if [ ! ${TERM_PROGRAM} = "vscode" ] && [ ! ${TERM_PROGRAM} = "tmux" ]; then
#  tmux_session_selector
#fi
export PATH="/opt/homebrew/opt/libpq/bin:/Users/yyamashi/gitrepo/llama.cpp/build/bin:$PATH"
