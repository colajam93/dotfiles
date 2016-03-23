set t_Co=256
set number
syntax on
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent
set cursorline
set laststatus=2 
set statusline=%F\ %r%m%h%w%=%y\ [%04l/%04L,\ %04v]
set cino=N-s
"set shell=bash\ --rcfile\ ~/.shell_common.sh\ -i

"if vim slow 
"set lazyredraw
"set ttyfast

"if not using archlinux.vim
"set backspace=indent,eol,start

augroup filetypedetect
    au BufRead,BufNewFile *.md set filetype=markdown
augroup END


"NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=~/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('~/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'scrooloose/syntastic'
"NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'Yggdroot/indentLine'
"NeoBundle 'w0ng/vim-hybrid'
NeoBundle 'cocopon/iceberg.vim'
NeoBundle 'shiracamus/vim-syntax-x86-objdump-d'
"NeoBundle 'embear/vim-localvimrc'

NeoBundleLazy 'justmao945/vim-clang', {
\    'autoload': {
\        'filetypes': ['cpp', 'c']}
\}

NeoBundleLazy 'rhysd/vim-clang-format', {
\    'autoload': {
\        'filetypes': ['cpp', 'c']}
\}

NeoBundleLazy 'plasticboy/vim-markdown', {
\    'autoload': {
\        'filetypes': ['markdown']}
\}

NeoBundleLazy 'godlygeek/tabular', {
\    'autoload': {
\        'filetypes': ['markdown']}
\}

NeoBundleLazy 'vim-jp/vim-go-extra', {
\    'autoload': {
\        'filetypes': ['go']}
\}

NeoBundleLazy 'Blackrush/vim-gocode', {
\    'autoload': {
\        'filetypes': ['go']}
\}

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------

"syntastic
"set statusline+=%#warningmsg#
"set statusline+=%{SyntasticStatuslineFlag()}
"set statusline+=%*
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_loc_list = 0
let g:syntastic_python_checkers = ['pyflakes', 'pep8']
" let g:syntastic_cpp_no_include_search = 1
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options  = '-std=c++14 -Wall -Wextra -stdlib=libc++ -lc++abi'
let g:syntastic_c_compiler = 'clang'
let g:syntastic_c_compiler_options  = '-std=c11 -Wall'
"let g:syntastic_mode_map = { 'mode': 'passive',
"    \ 'active_filetypes': ['go'] }
let g:syntastic_go_checkers = ['go', 'golint']

"clang_complete
"let g:clang_auto_select = 1
"let g:clang_complete_auto = 0
"let g:clang_periodic_quickfix = 0
"let g:clang_complete_copen = 1
"let g:clang_use_library = 1
"let g:clang_close_preview = 1
let g:clang_c_options = '-std=c11 -Wall'
let g:clang_cpp_options = '-std=c++14 -stdlib=libc++ -Wall'

" clang-format
let g:clang_format#auto_format = 1

"vim_markdown
let g:vim_markdown_folding_disabled=1

"colorscheme
colorscheme iceberg
"hi Normal ctermbg=none
"hi Visual ctermbg=LightYellow
hi Visual ctermbg=231
hi MatchParen ctermbg=darkblue

"hybrid
"hi LineNr ctermfg=gray
"hi StatusLine ctermbg=black ctermfg=gray
"hi Normal ctermbg=none
"hi Visual ctermbg=LightYellow
"hi MatchParen ctermbg=darkblue

" indent_guides
"let g:indent_guides_auto_colors = 0
"let g:indent_guides_enable_on_vim_startup = 1
"let g:indent_guides_guide_size = 1
"hi IndentGuidesOdd  ctermbg=gray
"hi IndentGuidesEven ctermbg=darkgrey
"let g:indent_guides_start_level = 2

" indentLine
let g:indentLine_color_term = 63
let g:indent_guides_start_level = 2

" yapf
map <C-Y><C-F> :call yapf#YAPF()<cr>
imap <C-Y><C-F> <c-o>:call yapf#YAPF()<cr>
