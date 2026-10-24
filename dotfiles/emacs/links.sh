script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dfl_link_add "$script_dir/init.el" "$HOME/.emacs.d/init.el"
