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

if !exists('g:outline_buf_name')
    g:outline_buf_name = "Outline"
endif

if !exists('g:outline_win_size')
     g:outline_win_size = 29
endif

var outline_options_default = {
            \ "python": [1]
            \ }

if exists('g:outline_options')
    extend(outline_options_default, g:outline_options, "force")
endif
g:outline_options = outline_options_default

# Mapping
import "../lib/outline.vim"
noremap <unique> <script> <Plug>Outline! :call <SID>outline.OutlineToggle()<cr>

if !hasmapto("<Plug>Outline!" ) || empty(mapcheck("<F8>", "n"))
    nnoremap <silent> <unique> <F8> <Plug>Outline!
endif
