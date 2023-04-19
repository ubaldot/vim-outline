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

g:outline_loaded = true


# --------------------------
# User settings
# --------------------------
if !exists('g:outline_buf_name')
    g:outline_buf_name = "Outline!"
endif

if !exists('g:outline_win_size')
     g:outline_win_size = 30
endif

if !exists('g:outline_include_before_exclude')
g:outline_include_before_exclude = {
            \ "python": false,
            \ "vim": false
            \ }
endif

# TODO Overwrite patterns or append? => Overwrite
if !exists('g:outline_pattern_to_include')
g:outline_pattern_to_include = {
            \ "python": ['^class', '^\s*def'],
            \ "vim": ['^\s*export', '^\s*def', '^\S*map',
                \ '^\s*\(autocmd\|autocommand\)', '^\s*\(command\|cmd\)',
                \ '^\s*sign' ]
            \ }
endif


# TODO Overwrite patterns or append?
if !exists('g:outline_pattern_to_exclude')
g:outline_pattern_to_exclude = {
            \ "python": ['^\s*def\s_\{-1,2}'],
            \ "vim": ['^\s*#']
            \ }
endif


# --------------------------
# Mapping
# --------------------------
import autoload "../lib/outline.vim"

noremap <unique> <script> <Plug>OutlineToggle :call <SID>outline.Toggle()<cr>
if !hasmapto("<Plug>OutlineToggle" ) || empty(mapcheck("<F8>", "n"))
    nnoremap <silent> <unique> <F8> <Plug>OutlineToggle
endif

noremap <unique> <script> <Plug>OutlineRefresh :call <SID>outline.Refresh()<cr>
if !hasmapto("<Plug>OutlineRefresh" ) || empty(mapcheck("<F7>", "n"))
    nnoremap <silent> <unique> <F7> <Plug>OutlineRefresh
endif

noremap <unique> <script> <Plug>OutlineGo :call <SID>outline.GoToOutline()<cr>
if !hasmapto("<Plug>OutlineGo" ) || empty(mapcheck("<F6>", "n"))
    nnoremap <silent> <unique> <F6> <Plug>OutlineGo
endif



# Commands
if !exists(":Outline")
  command Outline :call <SID>outline.Toggle()
endif
