" Redirector script! Hardlink this file to your $HOME directory and rename to _vimrc
"
" redirector_largerFont.vim: Uses larger font.

source $HOME/vimfiles/vimrc.vim

if has("gui_running")
   set guioptions-=T " Remove toolbar
   set guioptions-=m " Remove menu
   set guifont=Consolas:h10
endif
