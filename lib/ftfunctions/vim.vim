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
        return outline
                \ ->filter("v:val =~ "
                \ .. string(join(g:outline_pattern_to_include["vim"], '\|')))
                \ ->filter("v:val !~ "
                \ .. string(join(g:outline_pattern_to_exclude["vim"], '\|')))
    else
        return outline ->filter("v:val !~ "
                \ .. string(join(g:outline_pattern_to_exclude["vim"], '\|')))
                \ ->filter("v:val =~ "
                \ .. string(join(g:outline_pattern_to_include["vim"], '\|')))
    endif
    # TODO: Add a if you want to show line numbers?
enddef
