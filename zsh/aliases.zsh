### Alias

case "$(uname -s)" in
  Darwin)
    alias ll="gls -alh --color=auto"
    alias sed='gsed'
    alias grep='ggrep'
    ;;
  *)
    alias ll="ls -alh --color=auto"
    ;;
esac

alias less='less -r -SX'
alias gip="egrep -o '([1-2]?[0-9]{0,2}\.){3,3}[1-2]?[0-9]{0,2}'"
alias dyy="date '+%Y%m%d%H%M%S'"
alias vi='nvim'
alias vim='nvim'
alias nvf='nvim -d'
alias sudo='sudo '
alias tk='texit'
alias history='history 0'
alias gpip='`which python3` -m pip'
alias certbot='certbot --config-dir ./config --work-dir ./work --logs-dir ./logs'
alias mkfile='install -D /dev/null'
alias z='zellij'
