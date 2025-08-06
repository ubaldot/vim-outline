vim9script

# TODO: Jumps to be redefined!
# This file contains regex for filter out the current buffer and create catchy
# outline. Generally, the process happens in two steps:
#   1. filter -> capture the lines that you want to place in the outline,
#   2. sanitize -> the lines may be visually ugly, so you can make them nicer
#      before you place them in the Outline buffer.

def PythonDocstringFilter(): any
  var in_docstring = false
  return (_, line) => {
    if line =~ '.*""".*"""'
      return false
    elseif line =~ '"""'
      in_docstring = !in_docstring
      return false
    elseif in_docstring
      return false
    endif
    return true
  }
enddef

export var patterns = {
  python: [
    PythonDocstringFilter(),
    (_, val) => val !~ '^\s*def\s_\{-1,2}',
    (_, val) => val =~ '\v(^class|^\s*def)',
  ],
  vim: [
    (_, val) => val !~ '^\s*#',
    (_, val) => val =~ '\v(^\s*export |^\s*def |^\S*map|^\s*sign '
                                .. '|autocmd|autocommand|command|cmd)',
  ],
  tex: [
    (_, val) => val =~ "^\\\\\\w*section"
  ],
  markdown: [
    (_, val) => val =~ '^\s*#'
  ],
  java: [
    (_, val) => val =~ '\v(^\s*class |^\s*public |^\s*private |\s*protected )'
  ],
  go: [
    (_, val) => val =~ '\v(^func |^type )'
  ],
  odin: [(_, val) => val =~ '\v^[a-zA-Z0-9]+ :: ']
}

# For having a nice layout
export var sanitizers = {
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
