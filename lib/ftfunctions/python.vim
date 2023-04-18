vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the outline window.
# =================================================

# TODO: Remove?
export def CurrentItem(curr_item: string): string
    return trim(matchstr(curr_item, '\v\w+\s+\zs\w+'))
enddef

# TODO Parametrize the regex input
export def PreProcessOutline(win_id: number, outline: list<string>): list<string>

    # TODO: keep here?
    win_execute(win_id, 'setlocal syntax=python')

    # Docstrings removal
    # Init
    var ii = 0
    var is_docstring = false

    # Iteration
    # Most likely the user won't have the value of tmp_string
    # in any of his python comment or docstrings
    var tmp_string = "<hshnnTejwqik93la,AMNDNJFJKK3N2MNMAKPD+03mn2nhkalpdpk3nsla>"
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


# TODO This is the same in every function, it only changes the filetype.
export def FilterOutline(outline: list<string>): list<string>
    if g:outline_include_before_exclude["python"]
        return outline ->filter("v:val =~ " .. string(join(g:outline_pattern_to_include["python"], '\|')))
                        \ ->filter("v:val !~ " .. string(join(g:outline_pattern_to_exclude["python"], '\|')))
    else
        return outline ->filter("v:val !~ " .. string(join(g:outline_pattern_to_exclude["python"], '\|')))
                    \ ->filter("v:val =~ " .. string(join(g:outline_pattern_to_include["python"], '\|')))
    endif
    # TODO: Add a if you want to show line numbers?
enddef
