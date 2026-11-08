set nocompatible

if !has('nvim')
    set t_Co=256
endif

set number
syntax enable

" Use four spaces for indentation.
set tabstop=4
set expandtab
set shiftwidth=4
set softtabstop=4
set autoindent
set smartindent

set cursorline

" Search ignores case unless the pattern contains uppercase letters.
set incsearch
set hlsearch
set ignorecase
set smartcase

set laststatus=2
set statusline=%F\ %r%m%h%w%=%y\ [%04l/%04L,\ %04v]

set cino=N-s
set backspace=indent,eol,start

" Show an indentation guide at each four-space boundary.
set list
let &listchars = 'tab:> ,leadmultispace:|   '

filetype plugin indent on

" Clear search highlighting on idle or when entering Insert mode.
packadd! nohlsearch
