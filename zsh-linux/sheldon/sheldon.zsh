source "/root/.local/share/sheldon/repos/github.com/romkatv/zsh-defer/zsh-defer.plugin.zsh"
[[ ! -e /root/.local/share/sheldon/repos/github.com/junegunn/fzf/bin/fzf ]] && /root/.local/share/sheldon/repos/github.com/junegunn/fzf/install --bin
export PATH="/root/.local/share/sheldon/repos/github.com/junegunn/fzf/bin:$PATH"
source "/root/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/completion.zsh"
source "/root/.local/share/sheldon/repos/github.com/junegunn/fzf/shell/key-bindings.zsh"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/zsh-users/zsh-completions/zsh-completions.plugin.zsh"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/zsh-users/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/b4b4r07/enhancd/enhancd.plugin.zsh"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/romkatv/zsh-prompt-benchmark/zsh-prompt-benchmark.plugin.zsh"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/ohmyzsh/ohmyzsh/plugins/git/git.plugin.zsh"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/mafredri/zsh-async/async.plugin.zsh"
source "/root/.local/share/sheldon/repos/github.com/romkatv/powerlevel10k/powerlevel10k.zsh-theme"
zsh-defer source "/root/.local/share/sheldon/repos/github.com/zsh-users/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
autoload -Uz colors && zsh-defer colors
autoload -Uz compinit && zsh-defer compinit
