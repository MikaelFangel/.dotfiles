set relativenumber
set number
set number relativenumber

syntax on
set wrap

set autoindent
set smartindent
set smarttab
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

set ignorecase
set smartcase
set hlsearch

set wildmenu
set wildmode=longest:list,full

" Gdb debugging settings
packadd termdebug
let g:termdebug_popup = 0
let g:termdebug_wide = 163

" Cursor corshair style
hi CursorColumn guifg=NONE ctermfg=NONE guibg=#323232 ctermbg=236 gui=NONE cterm=NONE
hi CursorLine guifg=NONE ctermfg=NONE guibg=#323232 ctermbg=236 gui=NONE cterm=NONE
set cursorline
set cursorcolumn

" Vimdiff setup
if &diff
    syntax off
endif

" Nerdtree like setup for netrw
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 15
augroup ProjectDrawer
    autocmd!
    autocmd VimEnter * :Vexplore
    autocmd VimEnter * wincmd w
augroup END
