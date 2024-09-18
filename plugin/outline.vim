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

# TODO: these dictionaries don't need to be in the global namespace
# Define them as script-local and export them around.
if !exists('g:outline_include_before_exclude')
  g:outline_include_before_exclude = {
    python: false,
    vim: false,
    tex: false,
    markdown: true,
  }
endif

if !exists('g:outline_pattern_to_include')
  g:outline_pattern_to_include = {
    python: ['^class', '^\s*def'],
    vim: ['^\s*export', '^\s*def', '^\S*map',
          \ '^\s*\(autocmd\|autocommand\)', '^\s*\(command\|cmd\)',
          \ '^\s*sign ' ],
    tex: ["^\\\\\\w*section"],
    markdown: ['^\s*#']
  }
endif

if !exists('g:outline_pattern_to_exclude')
  g:outline_pattern_to_exclude = {
    python: ['^\s*def\s_\{-1,2}'],
    vim: ['^\s*#'],
    tex: [],
    markdown: []
  }
endif

# Each item is a list of substitutions to be used in order.
# Substitutions and its inverse shall match!
if !exists('g:outline_substitutions')
  g:outline_substitutions = {
    python: [],
    vim: [],
    tex: [{'\\section{\(.*\)}': '\1'},
      {'\\subsection{\(.*\)}': '  \1'},
      {'\\subsubsection{\(.*\)}': '    \1'},
      {'\\subsubsubsection{\(.*\)}': '      \1'}
    ],
    markdown: [
      {'\v^(\s*)(#)': '\2'},
      {'^#\+': "\\=repeat(' ', 2 * len(submatch(0)))"},
      {'^\s\{3}': ''}
    ]
  }
endif

# Each item is a list of substitutions to be used in order.
if !exists('g:outline_inverse_substitutions')
  g:outline_inverse_substitutions = {
    python: [],
    vim: [],
    tex: [{'\v^(\s?\w.*)$': '\\\\section{\1}'},
      {'\v^  (.*)$': '\\\\subsection{\1}'},
      {'\v^    (.*)$': '\\\\subsubsection{\1}'},
      {'\v^      (.*)$': '\\\\subsubsubsection{\1}'}
    ],
    markdown: [
    {'^\s*': "\\='#' .. repeat('#', len(submatch(0)) / 2) .. ' '"},
    ]
  }
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
