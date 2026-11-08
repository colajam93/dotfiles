function! DotfilesPlugins(manifest) abort
    let g:dotfiles_missing_plugins = []
    let l:manager = expand('~/.vim/autoload/plug.vim')

    " Use vim-plug only if it is already installed; startup never downloads it.
    if filereadable(l:manager)
        execute 'source' fnameescape(l:manager)
        call plug#begin(expand('~/.vim/plugged'))
    endif

    " Declare the same plugins as Neovim without installing missing ones.
    for l:plugin in json_decode(join(readfile(a:manifest), "\n"))
        if filereadable(l:manager)
            call plug#(l:plugin.src, {'as': l:plugin.name})
        endif

        if !filereadable(l:manager) || !isdirectory(expand('~/.vim/plugged/') . l:plugin.name)
            call add(g:dotfiles_missing_plugins, l:plugin.name)
        endif
    endfor

    " Enable installed plugins and select the appropriate setup hint.
    if filereadable(l:manager)
        call plug#end()
        let g:dotfiles_plugin_hint = ':PlugInstall'
    else
        let g:dotfiles_plugin_hint = 'install vim-plug in ~/.vim/autoload/plug.vim, then :PlugInstall'
    endif
endfunction
