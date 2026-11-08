" Use the dark palette regardless of the terminal's background detection.
set background=dark

" Keep a usable colorscheme even before plugins are installed.
if !empty(globpath(&runtimepath, 'colors/iceberg.vim'))
    colorscheme iceberg
    hi MatchParen ctermbg=darkblue
else
    colorscheme default
endif

if !empty(get(g:, 'dotfiles_missing_plugins', []))
    echomsg 'dotfiles: missing ' . join(g:dotfiles_missing_plugins, ', ')
                \ . '; ' . g:dotfiles_plugin_hint
endif
