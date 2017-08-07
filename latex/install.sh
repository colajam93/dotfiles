#!/usr/bin/env bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $script_dir/../lib/dotfiles.sh

latex_templates_dir=$HOME/.local/share/latex-templates
local_script_dir=$HOME/.local/bin
install -d $local_script_dir
install -d $latex_templates_dir
safe_install $script_dir/Makefile $latex_templates_dir
safe_install $script_dir/mystylefile.sty $latex_templates_dir
safe_install $script_dir/slide.tex $latex_templates_dir
safe_install $script_dir/report.tex $latex_templates_dir
safe_install $script_dir/latex-template $local_script_dir 755
