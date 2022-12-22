set nu
set ai
set ruler
set wrap
set linebreak
set showcmd
set noshowmode
set wildmenu

" color "
syntax on
set t_Co=256
set background=dark

" Important!!
if has('termguicolors')
	set termguicolors
endif

" For dark version.
set background=dark

" Set contrast.
" This configuration option should be placed before `colorscheme everforest`.
" Available values: 'hard', 'medium'(default), 'soft'
let g:everforest_background = 'medium'

" For better performance
let g:everforest_better_performance = 1

" colorscheme everforest "
colorscheme everforest

" search "
set incsearch
set hlsearch
set ignorecase

" tab & space "
set ts=2
set sw=2
set tabstop=2
set scrolloff=5

" copy & paster "
set clipboard=unnamed

" file "
filetype on
filetype indent on
filetype plugin on

" widowns "
set splitbelow
set splitright

" UTF8  "
set encoding=utf-8
set fileencodings=utf-8,chinese,latin-1
if has("win32")
	set fileencoding=chinese
else
	set fileencoding=utf-8
endif

" fix menu unicode encoding "
source $VIMRUNTIME/delmenu.vim
source $VIMRUNTIME/menu.vim
" fix consle unicode encdogin "
language messages zh_TW.utf-8

" plugins "
call plug#begin('~/.vim/plugged')

Plug 'ap/vim-css-color'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'sainnhe/everforest'

call plug#end()
