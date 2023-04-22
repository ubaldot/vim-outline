vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the outline window.
# =================================================

# TODO: Remove? This should go airline. Is it filetype dependent?
export def CurrentItem(curr_item: string): string
    return trim(matchstr(curr_item, '(.*'))
    # return trim(matchstr(curr_item, '\v\w+\s+\zs\w+'))
enddef

# TODO This is the same in every function, it only changes the filetype.
export def FilterOutline(outline: list<string>): list<string>
    if g:outline_include_before_exclude["python"]
        return outline
                \ ->filter("v:val =~ "
                \ .. string(join(g:outline_pattern_to_include["python"], '\|')))
                \ ->filter("v:val !~ "
                \ .. string(join(g:outline_pattern_to_exclude["python"], '\|')))
    else
        return outline
                    \ ->filter("v:val !~ "
                    \ .. string(join(g:outline_pattern_to_exclude["python"], '\|')))
                    \ ->filter("v:val =~ "
                    \ .. string(join(g:outline_pattern_to_include["python"], '\|')))
    endif
    # TODO: Add a if you want to show line numbers?
enddef
