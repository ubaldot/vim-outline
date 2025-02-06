vim9script

# This file contains regex for filter out the current buffer and create catchy
# outline. Generally, the process happens in two steps:
#   1. filter
#   2. substitute
#
# Sometimes you also need some sort of pre-processing, see e.g. python for
# removing the docstrings.
#
# However, there are some gotchas:
#   1. 'include' and 'exclude' operators are commutative if, and only if the
#      regex are disjoint. But in practice this never happens, so you must
#      specify if you want to first exclude or include a pattern from
#      filter().
#   2. Substitution shall be bijectives. That is, if b = a->substitute(X, Y,
#      ''), then you must secure that a = b->substitute(Y, X, '') otherwise
#      you won't be able to jump from a line of the Outline to the correct
#      line on the associated buffer.

export var outline_include_before_exclude = {
  python: false,
  vim: false,
  java: true,
  tex: false,
  markdown: true,
}

# For filter()
export var outline_pattern_to_include = {
  python: ['^class', '^\s*def'],
  vim: ['^\s*export', '^\s*def', '^\S*map',
        \ '^\s*\(autocmd\|autocommand\)', '^\s*\(command\|cmd\)',
        \ '^\s*sign ' ],
  tex: ["^\\\\\\w*section"],
  markdown: ['^\s*#'],
  java: ['^\s*class', '^\s*public', '^\s*private', '^\s*protected']
}

export var outline_pattern_to_exclude = {
  python: ['^\s*def\s_\{-1,2}'],
  vim: ['^\s*#']
}

# For substitute()
export var outline_substitutions = {
  tex: [{'\\section{\(.*\)}': '\1'},
    {'\\subsection{\(.*\)}': '  \1'},
    {'\\subsubsection{\(.*\)}': '    \1'},
    {'\\subsubsubsection{\(.*\)}': '      \1'}
  ],
  markdown: [
    {'\v^(\s*)(#)': '\2'},
    {'^#\+': "\\=repeat(' ', 2 * len(submatch(0)))"},
    {'^\s\{3}': ''}
  ],
}

export var outline_inverse_substitutions = {
  tex: [{'\v^(\s?\w.*)$': '\\\\section{\1}'},
    {'\v^  (.*)$': '\\\\subsection{\1}'},
    {'\v^    (.*)$': '\\\\subsubsection{\1}'},
    {'\v^      (.*)$': '\\\\subsubsubsection{\1}'}
  ],
  markdown: [
    {'^\s*': "\\='#' .. repeat('#', len(submatch(0)) / 2) .. ' '"},
  ],
}

# Pre-process functions

def RemoveDocstrings(outline: list<string>): list<string>
    # Docstrings removal
    # Init
    var ii = 0
    var is_docstring = false

    # Iteration
    # Most likely the user won't have the value of tmp_string
    # in any of his python comment or docstrings
    var tmp_string = "<hshnnTejwqik93la,AMK3N2MNMAKPD+03mn2nhkalpdpk3nsla>"
    for item in outline
        if item =~ '.*""".*"""' # Regular expression for finding docstrings
            outline[ii] = tmp_string
        elseif item =~ '"""' && item !~ '.*""".*"""'
            outline[ii] = tmp_string
            is_docstring = !is_docstring
        elseif is_docstring
            outline[ii] = tmp_string
        endif
        ii = ii + 1
    endfor

    # Actually remove dosctrings
    return outline ->filter("v:val !~ 'tmp_string'")
enddef

export var outline_pre_process = {
  python: RemoveDocstrings,
}

# User extensions.
if exists('g:outline_include_before_exclude')
  extend(outline_include_before_exclude, g:outline_include_before_exclude)
endif

if exists('g:outline_pattern_to_include')
  extend(outline_pattern_to_include, g:outline_pattern_to_include)
endif

if exists('g:outline_pattern_to_exclude')
  extend(outline_pattern_to_exclude, g:outline_pattern_to_exclude)
endif

# Each item is a list of substitutions to be used in order.
# Substitutions and its inverse shall match!
if exists('g:outline_substitutions')
  extend(outline_substitutions, g:outline_substitutions)
endif

# Each item is a list of substitutions to be used in order.
if exists('g:outline_inverse_substitutions')
  extend(outline_inverse_substitutions, g:outline_inverse_substitutions)
endif

if exists('g:outline_pre_process')
  extend(outline_pre_process, g:outline_pre_process)
endif
