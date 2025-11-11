# Colors can be changed by using zstyle with a pattern of the form :prompt:pure:$color_name and style color. The color names, their default, and what part they affect are:
#
# execution_time (yellow) - The execution time of the last command when exceeding PURE_CMD_MAX_EXEC_TIME.
# git:arrow (cyan) - For PURE_GIT_UP_ARROW and PURE_GIT_DOWN_ARROW.
# git:branch (242) - The name of the current branch when in a Git repository.
# git:branch:cached (red) - The name of the current branch when the data isn't fresh.
# host (242) - The hostname when on a remote machine.
# path (blue) - The current path, for example, PWD.
# prompt:error (red) - The PURE_PROMPT_SYMBOL when the previous command has failed.
# prompt:success (magenta) - The PURE_PROMPT_SYMBOL when the previous command has succeded.
# user (242) - The username when on remote machine.
# user:root (default) - The username when the user is root.
# virtualenv (242) - The name of the Python virtualenv when in use.
# The following diagram shows where each color is applied on the prompt:
#
# ┌───────────────────────────────────────────── path
# │          ┌────────────────────────────────── git:branch
# │          │       ┌────────────────────────── git:arrow
# │          │       │        ┌───────────────── host
# │          │       │        │
# ~/dev/pure master* ⇡ zaphod@heartofgold 42s
# venv ❯               │                  │
# │    │               │                  └───── execution_time
# │    │               └──────────────────────── user
# │    └──────────────────────────────────────── prompt
# └───────────────────────────────────────────── virtualenv
#
zmodload zsh/nearcolor
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f $ZSHRC_DIR/.p10k.zsh ]] || source $ZSHRC_DIR/.p10k.zsh
# zstyle :prompt:pure:path color '#30acec'

# User configuration
autoload colors && colors

#入力途中の履歴補完を有効化する
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
zmodload zsh/complist                                          # Menu listのbindkeyカスタマイズに必要

## 保管をインタラクティブに行う(https://stackoverflow.com/questions/68643931/zsh-s-tab-completion-overwrites-whats-next)
# zstyle ':completion:*' menu select=2
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;&|'
#zstyle ':completion:*' menu select=2 interactive
zstyle ':completion:*' menu select=2 interactive
# SPACESHIP_PROMPT_ADD_NEWLINE=false
# SPACESHIP_PROMPT_SEPARATE_LINE=false

### select=2: 補完候補を一覧から選択する。補完候補が2つ以上なければすぐに補完する。
#zstyle ':completion:*:default' menu select=2

## 補完候補をキャッシュする。
zstyle ':completion:*' use-cache yes
zstyle ':completion::complete:*' use-cache true
mkdir -p $HOME/.zsh/cache
zstyle ':completion:*' cache-path ~/.zsh/cache
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' keep-prefix
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*:manuals' separate-sections true
#zstyle ':completion:*' special-dirs true

#zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
#zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
#zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
#zstyle ':completion:*:options' description 'yes'
#zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT

### 補完方法毎にグループ化する。
#zstyle ':completion:*' format '%B%F{blue}%d%f%b'
#zstyle ':completion:*' group-name ''

### 補完侯補をメニューから選択する。
### 補完候補に色を付ける。
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

### 補完候補がなければより曖昧に候補を探す。
### m:{a-z}={A-Z}: 小文字を大文字に変えたものでも補完する。
### r:|[._-]=*: 「.」「_」「-」の前にワイルドカード「*」があるものとして補完する。
#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z} r:|[._-]=*'
### 文字の途中からも補完の対象にする
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

#zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' recent-dirs-insert both
#zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#' '^_.*$'
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
# Userは補完候補に出さない
zstyle ':completion:*' users
zstyle ':completion:*' parameter


# The !parameters part says to hide parameters when the completion is in -command- position, 環境変数を補完の候補に含めない
zstyle ':completion:*:-command-:*' tag-order '!parameters'


### 補完候補
### _oldlist 前回の補完結果を再利用する。
### _complete: 補完する。
### _match: globを展開しないで候補の一覧から補完する。
### _history: ヒストリのコマンドも補完候補とする。
### _ignored: 補完候補にださないと指定したものも補完候補とする。
### _approximate: 似ている補完候補も補完候補とする。
### _prefix: カーソル以降を無視してカーソル位置までで補完する。
#zstyle ':completion:*' completer _oldlist _complete _match _history _ignored _approximate _prefix
zstyle ':completion:*' completer _complete _ignored _approximate _prefix _match
#zstyle ':completion:*' completer _complete _approximate

## 詳細な情報を使わない
zstyle ':completion:*' verbose no

## sudo の時にコマンドを探すパス
#zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*:sudo:*' command-path /opt/homebrew/bin/ /opt/homebrew/sbin/ /usr/sbin /usr/bin /sbin /bin

rye_cache="$ZSHRC_DIR/zfunc/_rye"
if [ ! -e "$rye_cache" ]; then
  rye self completion -s zsh > $rye_cache
fi
unset rye_cache

fpath=($ZSHRC_DIR/zfunc $fpath)
fpath=(/opt/vagrant/embedded/gems/gems/vagrant-2.3.7/contrib/zsh $fpath)
compinit

# aws completion
autoload -Uz bashcompinit
bashcompinit

complete -C aws_completer aws


# Ctrl-Wでパスの文字列などをスラッシュ単位でdeleteできる
autoload -U select-word-style
select-word-style bash

# 最後に打った引数をコピー
autoload -Uz smart-insert-last-word
zstyle :insert-last-word match '*([[:alpha:]/\\]?|?[[:alpha:]/\\])*' # [a-zA-Z], /, \ のうち少なくとも1文字を含む長さ2以上の単語
zle -N insert-last-word smart-insert-last-word
bindkey '^[' insert-last-word
# see http://qiita.com/mollifier/items/1a9126b2200bcbaf515f
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY
setopt extended_history       # Historyの開始と終了を記録
setopt hist_expire_dups_first # 履歴を切り詰める際に、重複する最も古いイベントから消す
setopt hist_ignore_all_dups   # 履歴が重複した場合に古い履歴を削除する
setopt hist_save_no_dups      # 履歴ファイルに書き出す際、新しいコマンドと重複する古いコマンドは切り捨てる
setopt hist_ignore_dups       # 直前と同じコマンドラインはヒストリに追加しない
setopt hist_reduce_blanks     # 余分な空白は詰めて記録
setopt hist_no_store          # historyコマンドは履歴に登録しない
setopt share_history          # 全てのセッションで履歴を共有する
setopt correct                # コマンドをtypoしたときに聞きなおしてくれる
setopt list_packed            # 表示を詰めてくれる
#setopt auto_pushd            # cd -[tab]でcdのhistoryを閲覧できる
setopt noflowcontrol          # disable flow control
setopt auto_menu              # タブキーの連打で自動的にメニュー補完
setopt auto_list              # タブキーの連打で自動的にメニュー補完
setopt share_history          # tmuxなどを使っていてもhistoryを共有
setopt menu_complete          # Menuで出てくる候補を補完できるようにする
setopt prompt_subst           # プロンプト表示する度に変数を展開
setopt cdable_vars            # ディレクトリ補完でuserとかGroupを表示させない
setopt auto_param_slash       # ディレクトリ名の補完で末尾の / を自動的に付加し、次の補完に備える
setopt mark_dirs              # ファイル名の展開でディレクトリにマッチした場合 末尾に / を付加
setopt list_types             # 補完候補一覧でファイルの種別を識別マーク表示 (訳注:ls -F の記号)
setopt auto_menu              # 補完キー連打で順に補完候補を自動で補完
setopt auto_param_keys        # カッコの対応などを自動的に補完
setopt interactive_comments   # コマンドラインでも # 以降をコメントと見なす
setopt magic_equal_subst      # コマンドラインの引数で --prefix=/usr などの = 以降でも補完できる
unsetopt complete_in_word       # 語の途中でもカーソル位置で補完
setopt always_last_prompt     # カーソル位置は保持したままファイル名一覧を順次その場で表示し、終了時に画面から消す
setopt print_eight_bit        # 日本語ファイル名等8ビットを通す
setopt extended_glob          # 拡張グロブで補完(~とか^とか。例えばless *.txt~memo.txt ならmemo.txt 以外の *.txt にマッチ)
setopt globdots               # 明確なドットの指定なしで.から始まるファイルをマッチ
setopt auto_cd                # ディレクトリ名を入力するだけでcdできるようにする
#setopt ignoreeof              # Ctrl-Dでシェルからログアウトしない
setopt no_beep                # BEEPを鳴らさない
setopt nolistbeep             # no beep sound when complete list displayed
unsetopt beep


bindkey -e                                                    # Emacs keybind
bindkey -v '^t' peco-ssh                                      # 自作のpecoでsshホストを選択
bindkey -v '^a' beginning-of-line                             # 行頭へ(menuselectでは補完候補の先頭へ)
bindkey -v '^b' backward-char                                 # 1文字左へ(menuselectでは補完候補1つ左へ)
#bindkey -v 'b' backward-word                                  # 1文字右へ(menuselectでは補完候補1つ右へ)
bindkey -v '^e' end-of-line                                   # 行末へ(menuselectでは補完候補の最後尾へ)
bindkey -v '^d' delete-char                                   # 行末へ(menuselectでは補完候補の最後尾へ)
bindkey -v '^f' forward-char                                  # 1文字右へ(menuselectでは補完候補1つ右へ)
#bindkey -v 'f' forward-word                                  # 1文字右へ(menuselectでは補完候補1つ右へ)
bindkey -v '^h' backward-delete-char                          # 1文字削除(menuselectでは絞り込みの1文字削除)
bindkey -v '^i' expand-or-complete                            # 補完開始
bindkey -v "^K" kill-line
bindkey -v '^h' backward-delete-char                          # 1文字削除(menuselectでは絞り込みの1文字削除)
bindkey -v "^?" backward-delete-char                          # 1文字削除(menuselectでは絞り込みの1文字削除)
#bindkey "^f" history-incremental-search-forward   # 普通のリバースサーチ
#bindkey '^r' history-incremental-search-backward  # 普通のリバースサーチ
bindkey "^p" history-beginning-search-backward-end # 後ろだけリバースサーチ
bindkey "^n" history-beginning-search-forward-end  # 後ろだけリバースサーチ
#bindkey '^r' history-substring-search-up          # 打ってからリバースサーチ
#bindkey '^f' history-substring-search-down        # 打ってからリバースサーチ
#bindkey "^I" menu-complete   # 展開する前に補完候補を出させる(Ctrl-iで補完するようにする)
#bindkey "^I" list-expand

bindkey -M menuselect "^?" undo                                # 補完候補をbackspaceでキャンセル
bindkey -M menuselect '^d' undo
bindkey -M menuselect '^h' backward-delete-char                # 補完候補の文字を削除
#bindkey -M menuselect '^h' backward-char                      # 補完候補1つ左へ
#bindkey -M menuselect '^l' forward-char                       # 補完候補1つ右へ
bindkey -M menuselect '^i' forward-char                        # 補完候補1つ右へ
bindkey -M menuselect '^j' down-line-or-history                # 補完候補1つ下へ
bindkey -M menuselect '^k' up-line-or-history                  # 補完候補1つ上へ
bindkey -M menuselect '^r' history-incremental-search-forward  # 補完候補内インクリメンタルサーチ
bindkey -M menuselect '^[[Z' backward-char                     # shift+tabで候補を逆順で選択
#bindkey -M menuselect 'h' vi-backward-char
#bindkey -M menuselect 'j' vi-down-line-or-history
#bindkey -M menuselect 'k' vi-up-line-or-history
#bindkey -M menuselect 'l' vi-forward-char
#bindkey -M menuselect '^g' .send-break                        # send-break2回分の効果
#bindkey -M menuselect '^j' .accept-line                       # accept-line2回分の効果
#bindkey -M menuselect '^k' accept-and-infer-next-history      # 次の補完メニューを表示する
#bindkey -M menuselect '^n' down-line-or-history               # 補完候補1つ下へ
#bindkey -M menuselect '^p' up-line-or-history                 # 補完候補1つ上へ
#bindkey -M menuselect '^r' history-incremental-search-forward # 補完候補内インクリメンタルサーチ

# ctrl-y でcd ../を打つ
# function cd-up { zle push-line && LBUFFER='builtin cd ..' && zle accept-line }
# zle -N cd-up
# bindkey "^o" cd-up

#function cd-home { zle push-line && LBUFFER='builtin cd ~/' && zle accept-line }
#zle -N cd-home
#bindkey "^y" cd-home

bindkey "^[f" forward-word
bindkey "^[b" backward-word

xmodmap $HOME/Xmodmap 2> /dev/null
#xkbcomp -I $HOME/.xkb ~/.xkb/keymap/mykbd $DISPLAY 2> /dev/null

function tmux_session_selector() {
    PECO=/opt/homebrew/bin/peco
    if [[ ! $TMUX  && $- == *l* ]]; then
      ID=`tmux list-sessions`
      if [[ -z "$ID" ]]; then
        echo -n session_name:
        read session_name
        tmux new-session -s $session_name
      fi
      message="New Session"
      ID="${message}:\n$ID"
      #ID="`echo -e "$ID" | $PECO | cut -d: -f1`"
      ID="`echo -e "$ID" | $PECO | cut -d: -f1`"
      if [[ "$ID" = "${message}" ]]; then
        echo -n session_name:
        read  session_name
        if [ -z "$session_name" ]; then
          return
        fi
        tmux new-session -s $session_name
      elif [[ -n "$ID" ]]; then
        tmux attach-session -t "$ID"
      else
        :
      fi
    fi
  }

function timeout_child () {
    trap -- "" SIGTERM
    child=$!
    timeout=$1
    (
            sleep $timeout
            kill $child
    ) &
    wait $child
}

precmd() {
  if [ -d .git -a ! -x .git/hooks/pre-commit -a -e .pre-commit-config.yaml ] && which pre-commit >& /dev/null; then
    pre-commit install
  fi
  if [ -e .venv ] && [ ! -e .envrc ] && which direnv >& /dev/null; then
    cat << "EOF" > .envrc
if [ -e  .venv/ ]; then
  source .venv/bin/activate
fi
EOF
    direnv allow
  fi
}
#if [ ! ${TERM_PROGRAM} = "vscode" ] && [ ! ${TERM_PROGRAM} = "tmux" ]; then
#  tmux_session_selector
#fi

# for tmux
function _delete_or_exit() {
    if [[ -n "${BUFFER}" ]]
    then
        zle delete-char
    else
        local HISTORY_LIMIT=$(tmux show-options -g history-limit | awk '{print $2}')
        local SESSION=$(tmux display-message -p '#S')
        local WINDOW=$(tmux display-message -p '#I')
        local PANE=$(tmux display-message -p '#P')
        local DATE=$(date +%Y%m%d)
        local TIME=$(date +%Y%m%d-%H%M%S)
        local DIR="${HOME}/.tmux/logs/${DATE}"
        local FILE="${DIR}/${TIME}-${SESSION}-${WINDOW}.${PANE}.log"

        mkdir -p "$DIR"
        tmux capture-pane -S -$HISTORY_LIMIT
        tmux show-buffer > "$FILE"
        tmux display-message "Logging to $FILE"
        builtin exit
    fi
}

# makes C-d to detach tmux
if [[ -n "$TMUX" ]]
then
  setopt ignoreeof
  zle -N _delete_or_exit
  bindkey "^D" _delete_or_exit
fi

