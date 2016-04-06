#!/bin/sh

deinConfigDir=$HOME/.vim
install -d $deinConfigDir
install -m644 *.toml $deinConfigDir
install -m644 vimrc $HOME/.vimrc
