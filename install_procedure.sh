ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" < /dev/null 2> /dev/null\n
cat ./homebrew/brew_packages |xargs -I% -t brew install %
ln -s ~/gitrepo/bootstrap/zsh/.zshrc ./
ln -s ~/gitrepo/bootstrap/zsh/.zsh_env ./
ln -s gitrepo/bootstrap/tmux/.tmux.conf ./
ln -s ~/gitrepo/bootstrap/vim ~/.vim
ln -s ~/gitrepo/bootstrap/zsh/.p10k.zsh ~/.p10k.zsh
zsh
anyenv install pyenv
zplug install
pyenv install 3.10.6
pyenv global 3.10.6
cat ./pip3/pip3_packages |xargs -I% -t pip3 install %
