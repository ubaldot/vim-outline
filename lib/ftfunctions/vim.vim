vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

# TODO:remove
export def CurrentItem(curr_item: string): string
  return trim(substitute(curr_item, "(.*", "", ''))
enddef

# TODO This is the same in every function, it only changes the filetype.
export def FilterOutline(outline: list<string>): list<string>
  if g:outline_include_before_exclude["vim"]
    outline
          \ ->filter("v:val =~ "
          \ .. string(join(g:outline_pattern_to_include["vim"], '\|')))
          \ ->filter("v:val !~ "
          \ .. string(join(g:outline_pattern_to_exclude["vim"], '\|')))
  else
    outline ->filter("v:val !~ "
          \ .. string(join(g:outline_pattern_to_exclude["vim"], '\|')))
          \ ->filter("v:val =~ "
          \ .. string(join(g:outline_pattern_to_include["vim"], '\|')))
  endif
  # TODO: Add a if you want to show line numbers?
  #
  # Substitute. OBS! There shall be a 1-1 mapping in the substitution,
  # otherwise the inverse cannot be computed!
  if !empty(g:outline_substitutions["vim"])
    for subs in g:outline_substitutions["vim"]
      outline ->map((idx, val) => substitute(val, keys(subs)[0], values(subs)[0], ''))
    endfor
  endif

  return outline
enddef

export def InverseSubstitution(outline_item: string): string
  # Given a string in the outline, it reconstruct the string in the original
  # file
  var tmp = outline_item
  if !empty(g:outline_inverse_substitutions["vim"])
    for subs in g:outline_inverse_substitutions["vim"]
      tmp = tmp ->substitute(keys(subs)[0], values(subs)[0], '')
    endfor
  endif
  return tmp
enddef
