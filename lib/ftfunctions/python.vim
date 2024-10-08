vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the outline window.
# =================================================

import autoload "../regex.vim"

# TODO: Remove? This should go airline. Is it filetype dependent?
export def CurrentItem(curr_item: string): string
  return trim(matchstr(curr_item, '(.*'))
  # return trim(matchstr(curr_item, '\v\w+\s+\zs\w+'))
enddef

# TODO This is the same in every function, it only changes the filetype.
export def FilterOutline(outline: list<string>): list<string>
  if regex.outline_include_before_exclude["python"]
    outline
          \ ->filter("v:val =~ "
          \ .. string(join(regex.outline_pattern_to_include["python"], '\|')))
          \ ->filter("v:val !~ "
          \ .. string(join(regex.outline_pattern_to_exclude["python"], '\|')))
  else
    outline
          \ ->filter("v:val !~ "
          \ .. string(join(regex.outline_pattern_to_exclude["python"], '\|')))
          \ ->filter("v:val =~ "
          \ .. string(join(regex.outline_pattern_to_include["python"], '\|')))
  endif
  # TODO: Add a if you want to show line numbers?
  #
  # Substitute. OBS! There shall be a 1-1 mapping in the substitution,
  # otherwise the inverse cannot be computed!
  if !empty(regex.outline_substitutions["python"])
    for subs in regex.outline_substitutions["python"]
      outline ->map((idx, val) => substitute(val, keys(subs)[0], values(subs)[0], ''))
    endfor
  endif

  return outline
enddef

export def InverseSubstitution(outline_item: string): string
  # Given a string in the outline, it reconstruct the string in the original
  # file
  var tmp = outline_item
  if !empty(regex.outline_inverse_substitutions["python"])
    for subs in regex.outline_inverse_substitutions["python"]
      tmp = tmp ->substitute(keys(subs)[0], values(subs)[0], '')
    endfor
  endif
  return tmp
enddef
