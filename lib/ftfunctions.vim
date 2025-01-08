vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

import autoload "./regex.vim"

export def FilterOutline(outline: list<string>, filetype: string): list<string>
  if regex.outline_include_before_exclude[filetype]
    outline
          \ ->filter("v:val =~ "
          \ .. string(join(regex.outline_pattern_to_include[filetype], '\|')))
    if !empty(regex.outline_pattern_to_exclude[filetype])
      outline ->filter("v:val !~ "
          \ .. string(join(regex.outline_pattern_to_exclude[filetype], '\|')))
    endif
  else
    # In this case outline_pattern_to_exclude is cannot be empty
    outline ->filter("v:val !~ "
          \ .. string(join(regex.outline_pattern_to_exclude[filetype], '\|')))
          \ ->filter("v:val =~ "
          \ .. string(join(regex.outline_pattern_to_include[filetype], '\|')))
  endif

  # TODO: Add a if you want to show line numbers?
  # Substitute. OBS! There shall be a 1-1 mapping in the substitution,
  # otherwise the inverse cannot be computed!
  if !empty(regex.outline_substitutions[filetype])
    for subs in regex.outline_substitutions[filetype]
      outline ->map((idx, val) => substitute(val, keys(subs)[0], values(subs)[0], ''))
    endfor
  endif

  return outline
enddef

export def InverseSubstitution(outline_item: string, filetype: string): string
  # Given a string in the outline, it reconstruct the string in the original
  # file, so that the jump from the outline to the main buffer is accurate.
  var tmp = outline_item
  if !empty(regex.outline_inverse_substitutions[filetype])
    for subs in regex.outline_inverse_substitutions[filetype]
      tmp = tmp ->substitute(keys(subs)[0], values(subs)[0], '')
    endfor
  endif
  return tmp
enddef
