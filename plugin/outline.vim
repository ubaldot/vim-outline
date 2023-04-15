if !has('vim9script') ||  v:version < 900
  " Needs Vim version 9.0 and above
  echo "You need at least Vim 9.0"
  finish
endif

vim9script

# replica.vim
# github.com/ubaldot/vim-replica

if exists('g:outline_loaded')
    finish
endif

g:outline_loaded = 0

# User settings
g:outline_buf_name = "Outline"
g:outline_win_size = 29
g:outline_python_show_private = 0

if !exists('g:outline_buf_name')
    g:outline_buf_name = "Outline"
endif

if !exists('g:outline_win_size')
     g:outline_win_size = 29
endif

if !exists('g:outline_python_show_private')
     g:outline_python_show_private = 0
endif


# Mapping
import "../lib/outline.vim"
noremap <unique> <script> <Plug>Outline! :call <SID>outline.OutlineToggle(g:outline_python_show_private)<cr>

if !hasmapto("<Plug>Outline!" ) || empty(mapcheck("<F8>", "n"))
    nnoremap <silent> <unique> <F8> <Plug>Outline!
endif
