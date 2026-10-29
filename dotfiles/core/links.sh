script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dfl_link_add "$script_dir/gitconfig" "$HOME/.gitconfig"
dfl_link_add "$script_dir/tmux.conf" "$HOME/.tmux.conf"
dfl_link_add "$script_dir/gitignore_global" "$HOME/.config/git/ignore"
dfl_link_add "$script_dir/bat.conf" "$HOME/.config/bat/config"
dfl_link_add "$script_dir/lazygit.yml" "$HOME/.config/lazygit/config.yml"
dfl_link_add "$script_dir/npmrc" "$HOME/.npmrc"
dfl_link_add "$script_dir/pnpm.yaml" "$HOME/.config/pnpm/config.yaml"
