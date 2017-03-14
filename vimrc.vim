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

" Automatically reload the file if it's been changed externally
set autoread

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

" Themes
if has("gui_running")
   set guioptions-=T " Remove toolbar
   set guioptions-=m " Remove menu
   set guifont=Consolas:h8
endif

" Wrap navigation past beginning and end of a line
set whichwrap+=<,>,h,l,[,]

augroup filetypedetect_customer
   autocmd!
   " .md should be markdown not modula2
   autocmd BufNewFile,BufRead *.md setl ft=markdown
   autocmd FileType markdown set spell

   " Open .xaml as .xml
   autocmd BufNewFile,BufRead *.xaml setl filetype=xml

   " Open .def as .cpp
   autocmd FileType def set filetype=cpp

   " Open .py3 as python
   autocmd BufNewFile,BufRead *.py3 setl filetype=python

   " Autocomplete for .cs files
   autocmd FileType cs inoremap <C-space> <C-x><C-o><C-p>

   " Quickfix open in new vsplit
   autocmd! FileType qf nnoremap <buffer> <leader><CR> <C-w><CR><C-w>r

   " Set filetype to Configuration file
   autocmd BufNewFile,BufRead package set ft=conf
augroup END

" On Windows, open gvim maximized
autocmd GUIEnter * simalt ~x

" If a vim instance already has opened some file, go to that instance instead
" of warning about an open file
packadd! editexisting

"=========
" Mappings
"=========
" &actualvimrc will contain the path of this script,
" and not the name of the file trying to source this script
let actualvimrc = expand("<sfile>")
let actualvimrcdir = expand("<sfile>:p:h")
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

" Toggle line wrapping with the horizontal scrollbar
nnoremap <silent><expr> <F4> ':set wrap! go'.'-+'[&wrap]."=b\r"

" Change font to support Japanese
function! ToggleJapaneseFont()
   if &guifont==?"Consolas:h8"
      set guifont=MS_Gothic
      set encoding=utf-8
   else
      set guifont=Consolas:h8
   endif
endfunction
nnoremap <F5> :call ToggleJapaneseFont()<cr>

nnoremap <F8>/ :let @*=substitute(@*, "\\", "/", "g")<cr>:echo @*<cr>
nnoremap <F8>\ :let @*=substitute(@*, "/", "\\", "g")<cr>:echo @*<cr>
nnoremap <F8>y :let @*=substitute(substitute(@*, "^P:", "Y:", "g"), "^p:", "y:", "g")<cr>:echo @*<cr>

command! Json %!python -m json.tool
command! Hexify r !xxd %

" <F9> Go to last error
nnoremap <F9> :source C:\Reason\bin\last.vim<cr>

" <F10> Vimgrep shortcuts
" Regex search across multiple files
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

command! P4changes :below new | r !p4 changes -u jijin -s pending -l<cr>

" C-backspace deletes previous word
inoremap <C-BS> <C-W>
cnoremap <C-BS> <C-W>

" Quit faster
nnoremap <S-Q> :quit<CR>
vnoremap <S-Q> <esc>:quit<CR>
nnoremap <leader><C-Q><C-Q> :qall<CR>

" Static search, remap */# to be stationary until I press 'n' or something
nnoremap <silent> # :let @/=escape(expand('<cword>'), '\')<cr>:silent set hls<cr>
nnoremap <silent> * :let @/='\<'.escape(expand('<cword>'), '\').'\>'<cr>:silent set hls<cr>
" Map for double click
nmap <2-LeftMouse> *
" Search on selected text
vnoremap # y:let @/=@"<cr>:silent set hls<cr>
vnoremap * y:let @/='\<'.@".'\>'<cr>:silent set hls<cr>
" Go to next result and center
nnoremap <C-n> nzz
command! Lower let @/=tolower(@/) | echo @/
nnoremap <leader>l :Lower<cr>

" Next/Previous Tab
noremap <silent> <C-Tab> :tabnext<CR>
noremap <silent> <C-S-Tab> :tabprevious<CR>

" Move on what you see, rather than by strict lines
inoremap <silent> <Up> <Esc>gka
inoremap <silent> <Down> <Esc>gja

" Go to top of fold and center
nnoremap <S-k> zo[zzz

" Clear search highlights
nnoremap <S-space> :nohlsearch<CR>
vnoremap <S-space> <ESC>:nohlsearch<CR>

nmap , <Plug>(easymotion-prefix)s
vmap , <Plug>(easymotion-prefix)s

" Split screen navigation
nnoremap <silent> <C-h> :wincmd h<CR>
nnoremap <silent> <C-j> :wincmd j<CR>
nnoremap <silent> <C-k> :wincmd k<CR>
nnoremap <silent> <C-l> :wincmd l<CR>

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

" Shift the window up and down
nnoremap <m-j> 2<c-e>2<c-e>2<c-e>2<c-e>2<c-e>
vnoremap <m-j> 2<c-e>2<c-e>2<c-e>2<c-e>2<c-e>
nnoremap <m-k> 2<c-y>2<c-y>2<c-y>2<c-y>2<c-y>
vnoremap <m-k> 2<c-y>2<c-y>2<c-y>2<c-y>2<c-y>

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

" Turn a one line function into formatted multi line
nnoremap <F7> ^mvf(v%:s/,\@<=\s\+/\r/g<cr>`vf(a<cr><esc>`vf(v%=`v:nohlsearch<cr>

" Paste the system timestamp
nnoremap <s-m-f> "=strftime("%c")<cr>p
inoremap <s-m-f> <c-r>=strftime("%c")<cr>

""================
"" Plugin-specific
""================

" Install packages into 'plugged' directory
call plug#begin(actualvimrcdir . '\plugged')

Plug 'easymotion/vim-easymotion'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-vinegar'
Plug 'tpope/vim-surround'
Plug 'kien/ctrlp.vim'

Plug 'yegappan/mru'
Plug 'vim-scripts/a.vim'
Plug 'solarnz/thrift.vim'

call plug#end()

" vim-plug reference:
" Reload .vimrc and :PlugInstall to install plugins.
" :PlugUpdate to install or update
" :PlugClean to remove unused
" :PlugStatus

" a.vim:
" <F12> Switch from header file to .c/.cpp
nnoremap <F12> :A<CR>
nnoremap <C-S-F12> :AS<CR>
nnoremap <M-C-F12> :AV<CR>

" EasyMotion: Easier jumping around
" The leader approves of easymotion
nmap <leader> <Plug>(easymotion-prefix)
vmap <leader> <Plug>(easymotion-prefix)

" MRU: Remembers where I was
let MRU_Max_Entries = 5000
" Shortcut to open MRU
nnoremap <leader>m :MRU<cr>

" Airline:
let g:airline_theme="light"

" Vinegar:
nmap <F3> :topleft vsplit<cr><Plug>VinegarUp

" Ctrlp:
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = ['setupEnv.bat']

" OmniSharp:
" (and related)
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']
