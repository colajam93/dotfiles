script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dfl_link_add "$script_dir/vim/vimrc" "$HOME/.vimrc"
dfl_link_add "$script_dir/gvim/gvimrc" "$HOME/.gvimrc"
dfl_link_add "$script_dir/ideavim/ideavimrc" "$HOME/.ideavimrc"
dfl_link_add "$script_dir/nvim/init.lua" "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/init.lua"
