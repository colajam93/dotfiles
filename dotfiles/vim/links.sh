script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dfl_link_add "$script_dir/vimrc" "$HOME/.vimrc"
dfl_link_add "$script_dir/gvimrc" "$HOME/.gvimrc"
dfl_link_add "$script_dir/ideavimrc" "$HOME/.ideavimrc"
dfl_link_add "$script_dir/vimrc" "$HOME/.config/nvim/init.vim"
for name in plugins.toml plugins_lazy.toml; do
    dfl_link_add "$script_dir/$name" "$HOME/.vim/$name"
    dfl_link_add "$script_dir/$name" "$HOME/.config/nvim/$name"
done
