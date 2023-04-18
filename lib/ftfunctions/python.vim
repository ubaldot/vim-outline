vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

# TODO: Remove?
export def CurrentItem(curr_item: string): string
    return trim(matchstr(curr_item, '\v\w+\s+\zs\w+'))
enddef

# TODO Parametrize the regex input
export def PreProcessOutline(outline_win_id: number, Outline: list<string>): list<string>

    # ==============================================
    # SET OUTLINE WINDOW FILETYPE
    # ==============================================
    # TODO: remove?
    win_execute(outline_win_id, 'setlocal syntax=python')

    # Init
    var ii = 0
    var is_docstring = false

    # Iteration
    # Most likely the user won't have the value of tmp_string
    # in any of his python comment or docstrings
    var tmp_string = "<hshnnTejwqik93la,AMNDNJFJKK3N2MNMAKPD+03mn2nhkalpdpk3nsla>"
    for item in Outline
        if item =~ '.*""".*"""' # Regular expression for finding docstrings
            Outline[ii] = tmp_string
        elseif item =~ '"""' && item !~ '.*""".*"""'
            Outline[ii] = tmp_string
            is_docstring = !is_docstring
        elseif is_docstring
            Outline[ii] = tmp_string
        endif
        ii = ii + 1
    endfor

    # Actually remove dosctrings
    Outline = Outline ->filter("v:val !~ 'tmp_string'")

    return Outline
enddef
