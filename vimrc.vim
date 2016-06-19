" vimrc.vim
" by jxjin

" Very basic commands
set nocompatible
set nohidden
set autoindent
set shiftwidth=3
set softtabstop=3
set expandtab

set showcmd
set foldmethod=syntax
set foldlevel=99
set backspace=indent,eol,start
set number
set cursorline
set splitbelow
set splitright

set fileformats=dos
set shell=cmd.exe
set shellcmdflag=/c

" Automatically change dir on several events
set autochdir

" Tab completion in command mode
set wildmenu
set wildmode=list:longest,full

" Ignore case if no uppercase letters in query
set ignorecase
set smartcase

" Move and highlight when searching
set incsearch
set hlsearch

" Don't clutter up directories with .swp files,
" put them in special directories
set backup
set backupdir=$HOME/vimfiles/backup
set directory=$HOME/vimfiles/tmp

" Turn on persistent undo
set undodir=$HOME/vimfiles/undo
set undofile

" Syntax Highlighting
syntax on
filetype plugin indent on

" Restore cursor position to where it was before
augroup JumpCursorOnEdit
   autocmd!
   autocmd BufReadPost *
            \ if expand("<afile>:p:h") !=? $TEMP |
            \   if line("'\"") > 1 && line("'\"") <= line("$") |
            \     let JumpCursorOnEdit_foo = line("'\"") |
            \     let b:doopenfold = 1 |
            \     if (foldlevel(JumpCursorOnEdit_foo) > foldlevel(JumpCursorOnEdit_foo - 1)) |
            \        let JumpCursorOnEdit_foo = JumpCursorOnEdit_foo - 1 |
            \        let b:doopenfold = 2 |
            \     endif |
            \     exe JumpCursorOnEdit_foo |
            \   endif |
            \ endif
   " Need to postpone using "zv" until after reading the modelines.
   autocmd BufWinEnter *
            \ if exists("b:doopenfold") |
            \   exe "normal zv" |
            \   if(b:doopenfold > 1) |
            \       exe  "+".1 |
            \   endif |
            \   unlet b:doopenfold |
            \ endif
augroup END

" Always("2") show a status in the last window, with info on the file and location in file
set laststatus=2
" Left: Full file, modified?, readonly?, helpfile?, preview-window? (fileformat/encoding/font){filetype}
set statusline=%F%m%r%h%w\ (%{&ff}/%{&encoding}/%{&guifont}){%Y}
" Right: [virtual column, line number, virtual column]
set statusline+=%=[%v,\ %l\ of\ %L]

" Themes
if has("gui_running")
   set guioptions-=T " Remove toolbar
   set guioptions-=m " Remove menu
   set guifont=Consolas
endif

" Wrap navigation past beginning and end of a line
set whichwrap+=<,>,h,l,[,]

augroup filetypedetect_custom
   autocmd!
   " .md should be markdown not modula2
   autocmd BufNewFile,BufRead *.md setl ft=markdown
   autocmd BufNewFile,BufRead *.xaml setl filetype=xml
   autocmd FileType markdown set spell

   autocmd FileType def set filetype=cpp

   autocmd Syntax thrift source ~/vimfiles/thrift.vim

   " Autocomplete
   autocmd FileType cs nnoremap <C-space> <C-x><C-o><C-p>

augroup END

" On Windows, open gvim maximized
autocmd GUIEnter * simalt ~x

"=========
" Mappings
"=========
" &actualvimrc will contain the path of this script,
" and not the name of the file trying to source this script
let actualvimrc = expand("<sfile>")
execute "noremap <F1> :tabe" actualvimrc "<CR>"
noremap <C-F1> :source $MYVIMRC<CR>

" Space leader, backslash localleader
let mapleader=" "
let maplocalleader="\\"

" <F2> Copies current file/directory
nnoremap <leader><F2> :let @* = expand("%")<CR>:echo @*<CR>
nnoremap <F2> :let @* = expand("%:p:h")<CR>:echo @*<CR>
nnoremap <S-F2> :let @* = expand("%:p")<CR>:echo @*<CR>
nnoremap <M-F2> :let @* = expand("%:p:h")<CR>:echo @*<CR>:silent !explorer.exe <c-r>*<cr>

" Show the current file in the NERDTree windows
nnoremap <F3> :NERDTreeFind<CR>

" Toggle line wrapping with the horizontal scrollbar
nnoremap <silent><expr> <F4> ':set wrap! go'.'-+'[&wrap]."=b\r"

" Change font to support Japanese
function! ToggleJapaneseFont()
   if &guifont==?"Consolas"
      set guifont=MS_Gothic
      set encoding=utf-8
   else
      set guifont=Consolas
   endif
endfunction
nnoremap <F5> :call ToggleJapaneseFont()<cr>

" Set filetype to Configuration file
nnoremap <F6> :set ft=conf<cr>

" Note: There are no mappings on <F7>

nnoremap <F8>/ :let @*=substitute(@*, "\\", "/", "g")<cr>:echo @*<cr>
nnoremap <F8>\ :let @*=substitute(@*, "/", "\\", "g")<cr>:echo @*<cr>
nnoremap <F8>y :let @*=substitute(substitute(@*, "^P:", "Y:", "g"), "^p:", "y:", "g")<cr>:echo @*<cr>

nnoremap <F9> !%python -m json.tool<cr>
nnoremap <C-F9> :r !xxd %<cr>

" <F10> Vimgrep shortcuts
" This is the best function in this file: regex search across multiple files
function! RecursiveVimGrepOnSlashRegister(restrictToSource)
   let savedDir = getcwd()
   silent copen
   execute "cd" savedDir
   " Grep on whatever's in the / register,
   " don't jump to the first result (/j)
   if a:restrictToSource
      vimgrep//j * source/**
   else
      vimgrep//j **
   endif
endfunction

nnoremap <F10> :pwd<CR>
nnoremap <S-F10> :cd ..<CR>:pwd<CR>
nnoremap <C-F10> :call RecursiveVimGrepOnSlashRegister(0)<cr>
nnoremap <C-M-F10> :call RecursiveVimGrepOnSlashRegister(1)<cr>
" Quickfix navigation for moving through grep entries
nnoremap <M-n> :cnext<CR>
nnoremap <M-S-n> :cprev<CR>

" <F11> Checkout in P4
nnoremap <M-C-F11> :!p4 edit %<CR><CR>
inoremap <M-C-F11> <esc>:!p4 edit %<CR><CR>

" <F12> Switch from header file to .c/.cpp
nnoremap <F12> :A<CR>
nnoremap <C-S-F12> :AS<CR>
nnoremap <M-C-F12> :AV<CR>

" C-backspace deletes previous word
inoremap <C-BS> <C-W>
cnoremap <C-BS> <C-W>

" Quit faster
nnoremap <S-Q> :quit<CR>
vnoremap <S-Q> <esc>:quit<CR>
nnoremap <leader><C-Q><C-Q> :qall<CR>

" Static search, remap */# to be stationary until I press 'n' or something
nnoremap <silent> # :let @/=escape(expand('<cword>'), '\')<cr>:silent set hls<cr>
nnoremap <silent> * :let @/='\V\<'.escape(expand('<cword>'), '\').'\>'<cr>:silent set hls<cr>
" Map for double click
nmap <2-LeftMouse> *
" Search on selected text
vnoremap # y:let @/=@"<cr>:silent set hls<cr>
vnoremap * y:let @/='\V\<'.@".'\>'<cr>:silent set hls<cr>
" Go to next result and center
nnoremap <C-n> nzz

" Next/Previous Tab
noremap <silent> <C-Tab> :tabnext<CR>
noremap <silent> <C-S-Tab> :tabprevious<CR>

" Move on what you see, rather than by strict lines
inoremap <silent> <Up> <Esc>gka
inoremap <silent> <Down> <Esc>gja

" Go to top of fold and center
nnoremap <M-k> zo[zzz

" Clear search highlights
" WHICH ONE WILL WIN? YOU DECIDE!!!
nnoremap <S-space> :nohlsearch<CR>
vnoremap <S-space> <ESC>:nohlsearch<CR>

nmap , <Plug>(easymotion-prefix)s
vmap , <Plug>(easymotion-prefix)s

" Split screen navigation
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-l> :wincmd l<CR>

" Quickfix open in new vsplit
autocmd! FileType qf nnoremap <buffer> <leader><CR> <C-w><CR><C-w>r

" Wrap $(...) around a word
inoremap ;4 <esc>vbo<esc>a)<esc>`<i$(<esc>%a
"nnoremap ;4 viw<esc>a)<esc>`<i$(<esc>%
" ALL-CAPS the last word in insert mode
inoremap ;2 <esc>viwU`>a

" Operation-pending on the next "perforcePath = ... ;"
onoremap i; :<c-u>execute "normal! /perforcePath\r:nohl\rf\/vt;"<cr>

" Start search with word-left boundary, and end with word-right boundary
nnoremap <leader>/ /\<
nnoremap <leader>? ?\<
cnoremap <c-enter> \><cr>

" Use arrow keys in command mode? Like a barbarian?
cnoremap <c-h> <left>
cnoremap <m-h> <c-left>
cnoremap <c-l> <right>
cnoremap <m-l> <c-right>
cnoremap <c-k> <up>
cnoremap <c-j> <down>
" Don't forget about <c-b> and <c-e> for beginning and end
" Also <c-w> for delete word and <c-u> for delete to start

" Use tab to shift the window up and down
nnoremap <tab> 2<c-e>2<c-e>2<c-e>2<c-e>2<c-e>
nnoremap <s-tab> 2<c-y>2<c-y>2<c-y>2<c-y>2<c-y>
vnoremap <tab> 2<c-e>2<c-e>2<c-e>2<c-e>2<c-e>
vnoremap <s-tab> 2<c-y>2<c-y>2<c-y>2<c-y>2<c-y>

" Find and remove whitespace at end of lines
nnoremap <leader>q /\s\+$<cr>
nnoremap <leader>Q :%s///g<cr>

" Move based on what's visually above rather than move up a line even if it
" takes up multiple visual lines
nnoremap j gj
nnoremap k gk

" Select all
vnoremap <c-a> Gogg

" We never hit :wq intentionally so disable it with an cabbrev
cabbrev wq echoerr "In this world, it's :w or be :q!'d!"

" Need to use objects/export instead of committed exports?
nnoremap <leader>i /export<cr>gnctrunk<esc>f/;lct;objects/export<esc>

" New line but go back to normal, seems kind of pointless
nnoremap <leader>o o<esc>
nnoremap <leader>O O<esc>

" <S-backspace> should delete back to underscore
inoremap <s-backspace> <esc>vT_s

""================
"" Plugin-specific
""================
"" NERDTree: The directory tree
"" Make the NERDTree window 40 chars wide
"let g:NERDTreeWinSize = 40
"" Show hidden files by default except . and ..
"let g:NERDTreeShowHidden = 1
"let g:NERDTreeIgnore = ['\.\.$', '\.$'] " regexes to ignore '.' and '..'
"" nerdtree-tabs handles the automatic opening, so no worries
"
"" EasyMotion: Easier jumping around
"" The leader approves of easymotion
"nmap <leader> <Plug>(easymotion-prefix)
"vmap <leader> <Plug>(easymotion-prefix)
"
"" MRU: Remembers where I was
"" Cache should have 2000 entries
"let MRU_Max_Entries = 2000
"" Shortcut to open MRU, and MRU only on package files
"nnoremap <leader>m :MRU<cr>
"nnoremap <leader>M :MRU package<cr>
"" Open up package file and show its file tree
"nmap <leader>x <cr>:only<cr>:NERDTree<cr>
"
"" SemanticHighlight:
"nnoremap <leader>. :SemanticHighlightToggle<cr>
"
"" Rainbow:
"let g:rainbow_active = 1
"
"" Pathogen:
"execute pathogen#infect()
"
"" Pencil: The current colorscheme
"colorscheme pencil
"set background=light
"let g:pencil_higher_contrast_ui = 1
"" Highlight is gray by default in pencil, set it to yellow
"hi Search guibg=Yellow
"
"" Airline:
"let g:airline_theme="light"
