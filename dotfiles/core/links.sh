script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dfl_link_add "$script_dir/gitconfig" "$HOME/.gitconfig"
dfl_link_add "$script_dir/tmux.conf" "$HOME/.tmux.conf"
dfl_link_add "$script_dir/gitignore_global" "$HOME/.config/git/ignore"
