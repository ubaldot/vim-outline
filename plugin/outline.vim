vim9script

# Vim plugin to get an outline for your scripts.
# Maintainer:	Ubaldo Tiberi
# License: BDS-3Clause

if !has('vim9script') ||  v:version < 900
  # Needs Vim version 9.0 and above
  echo "You need at least Vim 9.0"
  finish
endif

if exists('g:outline_loaded')
    finish
endif

g:outline_loaded = 1

# User settings
if !exists('g:outline_buf_name')
    g:outline_buf_name = "Outline"
endif

if !exists('g:outline_win_size')
     g:outline_win_size = 29
endif

var outline_options_default = {
            \ "python": [0]
            \ }

if exists('g:outline_options')
    extend(outline_options_default, g:outline_options, "force")
endif
g:outline_options = outline_options_default

# Mapping
import autoload "../lib/outline.vim"

noremap <unique> <script> <Plug>Outline! :call <SID>outline.OutlineToggle()<cr>
if !hasmapto("<Plug>Outline!" ) || empty(mapcheck("<F8>", "n"))
    nnoremap <silent> <unique> <F8> <Plug>Outline!
endif

noremap <unique> <script> <Plug>Refresh! :call <SID>outline.OutlineRefresh()<cr>
if !hasmapto("<Plug>Refresh!" ) || empty(mapcheck("<F7>", "n"))
    nnoremap <silent> <unique> <F7> <Plug>Refresh!
endif
