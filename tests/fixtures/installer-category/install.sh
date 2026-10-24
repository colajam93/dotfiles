printf 'ran\n' >> "$HOME/installer-ran"
printf '%s %s\n' "${_dfl_force:?}" "${_dfl_quiet:?}" > "$HOME/installer-options"
