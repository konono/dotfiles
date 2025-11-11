#/bin/bash
ZSHRC_PATH=`readlink -f .zshrc`
ZSH_PATH=`readlink -f .zshrc |sed -e 's/.zshrc//g'`
ln -s $ZSHRC_PATH $HOME/.zshrc
ln -s $ $ZSH_PATH $HOME/zsh
