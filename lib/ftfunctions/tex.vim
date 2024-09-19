vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

import autoload "../regex.vim"

# TODO:remove
export def CurrentItem(curr_item: string): string
  return trim(substitute(curr_item, "(.*", "", ''))
enddef

# TODO This is the same in every function, it only changes the filetype.
export def FilterOutline(outline: list<string>): list<string>
  outline->filter("v:val =~ "
        \ .. string(join(regex.outline_pattern_to_include["tex"], '\|')))
  if !empty(regex.outline_substitutions["tex"])
    for subs in regex.outline_substitutions["tex"]
      outline ->map((idx, val) => substitute(val, keys(subs)[0], values(subs)[0], ''))
    endfor
  endif

  return outline
enddef

export def InverseSubstitution(outline_item: string): string
  # Given a string in the outline, it reconstruct the string in the original
  # file
  var tmp = outline_item
  if !empty(regex.outline_inverse_substitutions["tex"])
    for subs in regex.outline_inverse_substitutions["tex"]
      tmp = tmp ->substitute(keys(subs)[0], values(subs)[0], '')
    endfor
  endif
  return tmp
enddef
