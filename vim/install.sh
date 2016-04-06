#!/bin/sh

deinConfigDir=$HOME/.config/dein
install -d $deinConfigDir
install -m644 *.toml $deinConfigDir
install -m644 vimrc $HOME/.vimrc
