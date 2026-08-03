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
alias z='~/.config/zellij/kono_develop/zellij/target/dev-opt/zellij'

gh-token-refresh() {
  if ! (( $+commands[gh] )); then
    echo "gh is not installed." >&2
    return 1
  fi

  # GITHUB_TOKENが残っていても、保存済みのgh認証を更新する
  env -u GH_TOKEN -u GITHUB_TOKEN \
    gh auth refresh --hostname github.com "$@" || return 1

  local token
  token="$(
    env -u GH_TOKEN -u GITHUB_TOKEN \
      gh auth token --hostname github.com 2>/dev/null
  )" || {
    echo "Failed to get token. Run 'gh auth login' first." >&2
    return 1
  }

  # mise専用。gh CLIには影響しない
  export MISE_GITHUB_TOKEN="$token"

  # 古い設定が現在のシェルに残っていた場合に除去
  unset GH_TOKEN GITHUB_TOKEN

  echo "GitHub credentials refreshed."
  echo "MISE_GITHUB_TOKEN updated (${#MISE_GITHUB_TOKEN} chars)."
}
