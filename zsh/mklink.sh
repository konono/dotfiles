#/bin/bash
ZSHRC_PATH=`readlink -f .zshrc`
ln -s $ZSHRC_PATH $HOME/.zshrc
