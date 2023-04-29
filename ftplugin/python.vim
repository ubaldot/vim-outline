vim9script


def OutlinePreProcessInternal(outline: list<string>): list<string>

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


import autoload "../lib/ftfunctions/python.vim"

b:OutlinePreProcessInternal = OutlinePreProcessInternal
b:FilterOutline = python.FilterOutline
b:CurrentItem = python.CurrentItem

# OBS! b:OutlinePreProcess (user-defined) shall be placed in the main
# /ftplugin folder
