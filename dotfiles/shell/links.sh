script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

dfl_link_add "$script_dir/common.sh" "$HOME/.shell/common.sh"
platform_specific_script="$script_dir/$(dfl_platform_name).sh"
if [[ -f $platform_specific_script ]]; then
    dfl_link_add "$platform_specific_script" "$HOME/.shell/platform.sh"
fi

for name in bash_profile bashrc zshrc; do
    dfl_link_add "$script_dir/$name" "$HOME/.$name"
done
