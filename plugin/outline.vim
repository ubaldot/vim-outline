vim9script noclear

# Vim plugin to get an outline for your scripts.
# Maintainer:	Ubaldo Tiberi
# GetLatestVimScripts: 6068 1 :AutoInstall: outline.vim
# License: BSD3-Clause.

if !has('vim9script') ||  v:version < 900
  # Needs Vim version 9.0 and above
  echo "You need at least Vim 9.0"
  finish
endif

if exists('g:outline_loaded')
  finish
endif
g:outline_loaded = true

# --------------------------
# User settings
# --------------------------
if !exists('g:outline_buf_name')
  g:outline_buf_name = "Outline!"
endif

if !exists('g:outline_win_size')
  g:outline_win_size = &columns / 4
endif

if !exists('g:outline_enable_highlight')
  g:outline_enable_highlight = true
endif

if !exists('g:outline_autoclose')
  g:outline_autoclose = false
endif


# --------------------------
# Mappings
# --------------------------
import autoload "../lib/outline.vim"

# noremap <unique> <script> <Plug>OutlineToggle
# \ :call <SID>outline.Toggle()<cr>
noremap <unique> <script> <Plug>OutlineToggle
      \ :call <SID>outline.Toggle()<cr>
if !hasmapto("<Plug>OutlineToggle" ) || empty(mapcheck("<F8>", "n"))
  nmap <silent> <unique> <F8> <Plug>OutlineToggle
endif

noremap <unique> <script> <Plug>OutlineRefresh
      \ :call <SID>outline.RefreshWindow()<cr>
if !hasmapto("<Plug>OutlineRefresh" ) || empty(mapcheck("<leader>l", "n"))
  nmap <silent> <unique> <leader>l <Plug>OutlineRefresh
endif

noremap <unique> <script> <Plug>OutlineGoToOutline
      \ :call <SID>outline.GoToOutline()<cr>
if !hasmapto("<Plug>OutlineGoToOutline" ) || empty(mapcheck("<leader>o", "n"))
  nmap <silent> <unique> <leader>o <Plug>OutlineGoToOutline
endif

# --------------------------
# Commands
# --------------------------
if !exists(":OutlineToggle")
  command OutlineToggle :call <SID>outline.Toggle()
endif

if !exists(":OutlineRefresh")
  command OutlineRefresh :call <SID>outline.RefreshWindow()
endif

if !exists(":OutlineGoToOutline")
  command OutlineGoToOutline :call <SID>outline.GoToOutline()
endif
