script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)" || return 1

dfl_link_add "$script_dir/gitconfig" "$HOME/.gitconfig" || return 1
dfl_link_add "$script_dir/tmux.conf" "$HOME/.tmux.conf" || return 1
dfl_link_add "$script_dir/gitignore_global" "$HOME/.config/git/ignore"
