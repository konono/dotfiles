#eval $(dircolors -b ~/.dirc)
#xinput set-prop 10 "Device Enabled" 0
# Profiling option
#  zmodload zsh/zprof && zprof


function peco-ssh () {
  local selected_host=$(awk '
  tolower($1)=="host" {
    for (i=2; i<=NF; i++) {
      if ($i !~ "[*?]") {
        print $i
      }
    }
  }
  ' ~/.ssh/config | sort | peco --query "$LBUFFER")
  if [ -n "$selected_host" ]; then
    BUFFER="ssh ${selected_host}"
    zle accept-line
  fi
  zle clear-screen
}
zle -N peco-ssh

function grvim(){
  # Init vars
  file=""
  line=""

  ARGS=()
  IGNORE_PATTERN=()
  IGNORE_PATTERN+=(-e ".git" -e "venv" -e ".tox")
  while (( $# > 0 ))
  do
    case $1 in
      -v)
        if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
          echo "'option' requires an argument." 1>&2
          exit 1
        else
          IGNORE_PATTERN+=(-e "$2")
          shift
        fi
        ;;
      *)
        ARGS=("${ARGS[@]}" "$1")
        ;;
    esac
    shift
  done

  if [[ "${#ARGS[@]}" -lt 1 ]]; then
    echo "Too few arguments." 1>&2
  elif [[ "${#ARGS[@]}" -gt 1 ]]; then
    echo "Too many arguments." 1>&2
  fi

  get_nth () {
    local n=$1
    shift
    eval echo \$${n}
  }

  REGEX_PATTERN=$(get_nth 1 "${ARGS[@]}")

  if [ ${#IGNORE_PATTERN[@]} -eq 0 ]; then
    res="`ggrep --color=auto -rI -n "$REGEX_PATTERN" |peco`"
  else
    res="`ggrep --color=auto -rI -n "$REGEX_PATTERN" |ggrep -v ${IGNORE_PATTERN[@]} |peco`"
  fi
  file="$(awk -F: -v t="$res" 'BEGIN{split(t, a); print a[1]}')"
  line="$(awk -F: -v t="$res" 'BEGIN{split(t, a); print a[2]}')"
  if [ -n "$file" ] && [ -n "$line" ]; then
    nvim -c $line $file
  else
    echo "...Canceled"
  fi
}

function texit(){
  if [[ -n "$TMUX" ]] ; then
    tmux run "mkdir -p ~/.tmux/logs/\$(date +%Y%m%d);tmux capture-pane -S -10000000; tmux show-buffer > \${HOME}/.tmux/logs/\$(date +%Y%m%d)/\$(date +%Y%m%d-%H%M%S)-#S-#I.#P.log" \; display-message "Logging ..."
    builtin exit
  else
    builtin exit
  fi
}

function td() {
  date +%Y%m%d%S
}

in_container() {
  container="$1"
  shift # command: the rest
  if [ -z "$*" ] ; then
    podman exec -it "$container" env PS1="$container $PS1" env TERM="$TERM" /bin/bash
  else
    podman exec "$container" env TERM="$TERM" "$@"
  fi
}


function tmux-remake-socket() {
    if [ ! $TMUX ]; then
        return
    fi
    tmux_socket_file=`echo $TMUX|awk -F, '{print $1}'`
    if [ ! -S $tmux_socket_file ]; then
        mkdir -m700 `dirname $tmux_socket_file` 2> /dev/null
        killall -SIGUSR1 tmux
    else
        echo tmux unix domain socket exists! nothing to do.
    fi
    unset tmux_socket_file
}
