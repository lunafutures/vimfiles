" vimrc.vim
" Note for ubuntu, first install packages: git vim vim-gtk3 curl

" Very basic commands
set nocompatible
set nohidden
set autoindent
set shiftwidth=3
set softtabstop=3
set tabstop=3
set expandtab

set showcmd
set foldmethod=manual
set foldlevel=99
set backspace=indent,eol,start
set number
set cursorline
set splitbelow
set splitright

if has('win32')
   set fileformats=dos
   set shell=cmd.exe
   set shellcmdflag=/c
elseif has('unix')
   set fileformats=unix
   set shell=bash
   set shellcmdflag=-c
endif

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

if has('win32')
   set backupdir=$HOME/vimfiles/backup
   set directory=$HOME/vimfiles/tmp
elseif has('unix')
   set backupdir=$HOME/.vim/backup
   set directory=$HOME/.vim/tmp
endif

" Turn on persistent undo
set undodir=$HOME/.vim/undo
set undofile

" Add < and > to matching using the % command
set matchpairs+=<:>

let g:devolutionMessage = "Devolved command not defined."

" Syntax Highlighting
syntax on
filetype plugin indent on

" Constant strings
function! Str2NrList(str)
   let nrList = []
   for i in range(len(a:str))
      let nr = char2nr(a:str[i])
      call add(nrList, nr)
   endfor
   return nrList
endfunction

function! NrList2Str(nrList)
   let str = ""
   for nr in a:nrList
      let str = str . nr2char(nr)
   endfor
   return str
endfunction

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

   if has('win32')
      set guifont=Consolas:h12
      " On Windows, open gvim maximized
      autocmd GUIEnter * simalt ~x
   endif
endif

" Wrap navigation past beginning and end of a line
set whichwrap+=<,>,h,l,[,]

function! HighlightMatchingXMLTags()
   let matchList = matchlist(getline("."), "^\\s\\+<\\S\\+")
   if len(matchList) == 0
      echoerr "No match found"
      return
   endif
   let sub2 = substitute(matchList[0], "</", '<', '')
   let sub1 = substitute(sub2, ">", '', '')
   let subbed = substitute(sub1, "<", '<\\/\\?', '')
   let angleIndex = strgetchar(subbed, '<')
   let search = "^" . subbed
   let @/ = search
   echo search
endfunction

let g:spacesForPython=4

" Type ":autocmd vimrc" to check that your settings have committed.
augroup vimrc
   autocmd!
   " .md should be markdown not modula2
   autocmd BufNewFile,BufRead *.md setlocal ft=markdown

   " Open .xaml as .xml
   autocmd BufNewFile,BufRead *.xaml setlocal filetype=xml
   autocmd BufNewFile,BufRead *.xaml nnoremap <buffer> <leader>, :call HighlightMatchingXMLTags()<CR>

   " Open .def as .cpp
   autocmd FileType def set filetype=cpp

   " Open .automagic as javascript (close enough)
   autocmd BufNewFile,BufRead *.automagic setlocal filetype=javascript

   " Open .py3 as python
   autocmd BufNewFile,BufRead *.py3 setlocal filetype=python

   execute "autocmd FileType Python setlocal tabstop=" . g:spacesForPython
   execute "autocmd FileType Python setlocal softtabstop=" . g:spacesForPython
   execute "autocmd FileType Python setlocal shiftwidth=" . g:spacesForPython

   " Autocomplete for .cs files
   autocmd FileType cs inoremap <C-space> <C-x><C-o><C-p>

   " Quickfix open in new vsplit
   autocmd! FileType qf nnoremap <buffer> <leader><CR> <C-w><CR><C-w>r

   " Set filetype to Configuration file
   autocmd BufNewFile,BufRead package set ft=conf

   " Open terminal logs with ColorToggle
   autocmd BufRead *.log ColorToggle

   autocmd BufNewFile,BufRead *o.txt setlocal ft=notes

   " Adjust the cwd every time we move into a buffer
   autocmd BufEnter cd expand("%:p:h")
augroup END

" If a vim instance already has opened some file, go to that instance instead
" of warning about an open file
packadd! editexisting

"=========
" Mappings
"=========
" Variable actualvimrc will contain the path of this script,
" and not the name of the file trying to source this script
let actualvimrc = expand("<sfile>")
let actualvimrcdir = expand("<sfile>:p:h")
execute "noremap <F1> :tabe" actualvimrc "<CR>"
noremap <C-F1> :source $MYVIMRC<CR>

" Space leader, backslash localleader
let mapleader=" "
let maplocalleader="\\"

" <F2> Group
" Get only the filename
nnoremap <leader><F2> :let @* = expand("%")<CR>:echo @*<CR>
" Get the absolute path of the directory (and not file)
nnoremap <C-F2> :let @* = expand("%:p:h")<CR>:echo @*<CR>
" Get the absolute path of the file
nnoremap <F2> :let @* = expand("%:p")<CR>:echo @*<CR>
" Show file in file explorer
nnoremap <M-F2> :silent execute '!explorer.exe /select,' . expand("%")<cr>
" Open the file in visual studio at the sample position
nnoremap <S-F2> :silent execute '!gotoVisualStudio %:p ' . line('.') . ' ' . col('.')<CR>
nnoremap <C-S-F2> :echoerr g:devolutionMessage<cr>

nnoremap <leader>2 :let @*=expand("%:p") . ':' . line('.')<cr>:echo @*<cr>

" Toggle line wrapping with the horizontal scrollbar
nnoremap <silent><expr> <F4> ':set wrap! go'.'-+'[&wrap]."=b\r"

" Change font to support Japanese
function! ToggleJapaneseFont()
   if &guifont==?"Consolas:h12"
      set guifont=MS_Gothic
      set encoding=utf-8
   else
      set guifont=Consolas:h12
   endif
endfunction
nnoremap <F5> :call ToggleJapaneseFont()<cr>

nnoremap <F6> :let @/="#region"<cr>nzz

nnoremap <F8>/ :let @*=substitute(@*, "\\", "/", "g")<cr>:echo @*<cr>
nnoremap <F8>\ :let @*=substitute(@*, "/", "\\", "g")<cr>:echo @*<cr>
nnoremap <F8>y :echoerr g:devolutionMessage<cr>
function! SaveTemp()
   execute "saveas $TEMP/" . strftime("Y%Y-M%m-d%d-%Hh-%Mm-%Ss") . ".txt"
endfunction
nnoremap <leader><F8> :call SaveTemp()<cr>

command! Json %!py -m json.tool
command! Hexify r !xxd %
command! No set nomodifiable

" <F10> Vimgrep shortcuts
" Regex search across multiple files
function! RecursiveVimGrepOnSlashRegister(restrictToSource, useNative)
   let savedDir = getcwd()
   silent copen
   execute "cd" savedDir
   echom "Searching in directory:" getcwd()

   if a:restrictToSource
      if a:useNative
         execute "grep /s /i \"" . @/ . "\" source/*"
      else
         " Grep on whatever's in the / register,
         " don't jump to the first result (/j)
         vimgrep//j * source/**
      endif
   else
      if a:useNative
         execute "grep /s /i \"" . @/ . "\" *"
      else
         vimgrep//j **
      endif
   endif
endfunction

nnoremap <F10> :echo getcwd()<CR>
nnoremap <S-F10> :cd ..<CR>:echo getcwd()<CR>

nnoremap <C-F10> :call RecursiveVimGrepOnSlashRegister(v:false, v:false)<cr>
nnoremap <C-M-F10> :call RecursiveVimGrepOnSlashRegister(v:true, v:false)<cr>
nnoremap <leader><F10> :vimgrep//j % \| copen<cr>

" Quickfix navigation for moving through grep entries
nnoremap <M-n> :cnext<CR>
nnoremap <M-S-n> :cprev<CR>

" C-backspace deletes previous word
inoremap <C-BS> <C-W>
cnoremap <C-BS> <C-W>

" Quit faster
nnoremap <C-W> :quit<CR>
vnoremap <C-W> <esc>:quit<CR>

nnoremap <S-Q> <C-W>

" Since <C-w> is mapped to <S-Q> it makes it harder to make windows equal
" size. Here's a workaround.
nnoremap <leader>= <C-W>=

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
nnoremap <C-F11> :set guifont=Consolas:h12<CR>

" Reserve <leader>8 and i;
nnoremap <leader>8 :echoerr g:devolutionMessage<cr>
onoremap i; :echoerr g:devolutionMessage<cr>

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

let s:linesToScroll = 10
execute "nnoremap <m-j> " . s:linesToScroll . "\<c-e>"
execute "vnoremap <m-j> " . s:linesToScroll . "\<c-e>"
execute "nnoremap <m-k> " . s:linesToScroll . "\<c-y>"
execute "vnoremap <m-k> " . s:linesToScroll . "\<c-y>"

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
cabbrev wq echoerr "In this world, it's :q or be :q!'d!"
cabbrev w' echoerr "You missed."

nnoremap <leader>i :echoerr g:devolutionMessage<cr>

" New line but go back to normal, seems kind of pointless
nnoremap <leader>o o<esc>
nnoremap <leader>O O<esc>

" Turn a one line function into formatted multi line
nnoremap <F7> ^mvf(v%:s/,\@<=\s\+/\r/g<cr>`vf(a<cr><esc>`vf(v%=gvoj<`v:nohlsearch<cr>

" Paste the system timestamp at cursor
nnoremap <s-m-f> "=strftime("%c")<cr>p
inoremap <s-m-f> <c-r>=strftime("%c")<cr>

" Ripped from http://www.danielbigham.ca/cgi-bin/document.pl?mode=Display&DocumentID=1053
" URL encode a string. ie. Percent-encode characters as necessary.
function! UrlEncode(string)
    let result = ""

    let characters = split(a:string, '.\zs')
    for character in characters
        if character == " "
            let result = result . "+"
        elseif CharacterRequiresUrlEncoding(character)
            let i = 0
            while i < strlen(character)
                let byte = strpart(character, i, 1)
                let decimal = char2nr(byte)
                let result = result . "%" . printf("%02x", decimal)
                let i += 1
            endwhile
        else
            let result = result . character
        endif
    endfor
    return result
endfunction

" Returns 1 if the given character should be percent-encoded in a URL encoded
" string.
function! CharacterRequiresUrlEncoding(character)
    let ascii_code = char2nr(a:character)
    if ascii_code >= 48 && ascii_code <= 57
        return 0
    elseif ascii_code >= 65 && ascii_code <= 90
        return 0
    elseif ascii_code >= 97 && ascii_code <= 122
        return 0
    elseif a:character == "-" || a:character == "_" || a:character == "." || a:character == "~"
        return 0
    endif
    return 1
endfunction

function! OpenURL(url)
   let encoded = UrlEncode(@v)
   let newURL = substitute(a:url, "XXX", encoded, 0)

   " Passing 1 to shell escape will escape !, #, which will then be striped
   " away by the :!

   "let command = "!rundll32 url.dll,FileProtocolHandler " . shellescape(newURL, 1)
   let command = "!chrome --profile-directory=\"Profile 1\" " . shellescape(newURL, 1)

   silent execute command
   echom command
endfunction

vnoremap g.r "vy:call OpenURL("https://referencesource.microsoft.com/#q=XXX")<cr>
vnoremap g.g "vy:call OpenURL("http://www.google.com/search?q=XXX")<cr>
vnoremap g.m "vy:call OpenURL("https://social.msdn.microsoft.com/search/en-US?query=XXX")<cr>

" Shortcuts for common Ctrl-P commands
" Open the filename under cursor in a regular split:
nmap <leader>p <C-P><C-\>w<C-s>
" Open the filename under cursor in a vsplit:
nmap <leader>v <C-P><C-\>w<C-v>
" Open the filename under cursor in the current window:
nmap <leader>o <C-P><C-\>w<cr>

" Paste from 0 AKA "yank-text-register" and won't work for deletes
nnoremap <leader>0 "0p

nnoremap go viW"fy:e <C-R>f<cr>
vnoremap go "fy:e <C-R>f<cr>
nnoremap gso viW"fy:split <C-R>f<cr>
vnoremap gso "fy:split <C-R>f<cr>

" Open url
if (has('win32') || has('win64'))
   nmap gx :exec "!start <cWORD>"<cr>
else
   nmap gx :exec "!open <cWORD>"<cr>
endif

""================
"" Plugin-specific
""================

if has('unix') && empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install packages into 'plugged' directory
call plug#begin(actualvimrcdir . '\plugged')

Plug 'easymotion/vim-easymotion'
"Plug 'vim-airline/vim-airline'
"Plug 'vim-airline/vim-airline-themes'
Plug 'tpope/vim-vinegar'
" Tips for vim-surround:
" * ds + surrounding character inside of a surrounder in order to remove it
" * Use visual mode to select the text you want, then press `S` + surrounding character to surround.
Plug 'tpope/vim-surround'
Plug 'kien/ctrlp.vim'

Plug 'yegappan/mru'
Plug 'jxjin/a.vim'
Plug 'solarnz/thrift.vim'
Plug 'chrisbra/Colorizer'
Plug 'morhetz/gruvbox'

Plug 'xolox/vim-notes'
Plug 'xolox/vim-misc'

Plug 'leafgarland/typescript-vim'

call plug#end()

" vim-plug reference:
" Reload .vimrc and :PlugInstall to install plugins.
" :PlugUpdate to install or update
" :PlugClean to remove unused
" :PlugStatus
"
let g:selectedColorScheme = "gruvbox"
execute "colorscheme" g:selectedColorScheme

" a.vim:
" <F12> Switch from header file to .c/.cpp
"nnoremap <F12> :A<CR>
"nnoremap <C-S-F12> :AS<CR>
"nnoremap <M-C-F12> :AV<CR>
inoremap <F12> <C-r>= "[" . substitute(strftime("%m/%d"), '\v0(\d)', '\1', 'g') . "]" <CR>


function! GoToModelOrView()
   if expand("%") =~ "Model.cs"
      let targetFilename = substitute(expand("%"), "Model.cs", ".xaml", "")
   else
      let barename = expand("%:r:r")
      let targetFilename = barename . "Model.cs"
   endif
   echo targetFilename
   execute "edit" targetFilename
endfunction
nnoremap <C-F12> :call GoToModelOrView()<cr>

" Copy all into the clipboard
nnoremap <leader><F12> gg<S-V>G"*y

" EasyMotion: Easier jumping around
" The leader approves of easymotion
nmap <leader> <Plug>(easymotion-prefix)
vmap <leader> <Plug>(easymotion-prefix)

" MRU: Remembers where I was
let MRU_Max_Entries = 5000
" Shortcut to open MRU
nnoremap <leader>m :MRU<cr>

" Airline:
let g:airline_theme="deus"

" Vinegar:
nmap <F3> :topleft vsplit<cr><Plug>VinegarUp

" Ctrlp:
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_root_markers = [".ctrlp_root_marker"]
nnoremap <leader><S-M> :CtrlPMRU<CR>
