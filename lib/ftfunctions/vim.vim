vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

export def PopulateOutlineWindow(outline_win_id: number, func_options: list<any>): list<string>


    # ==============================================
    # SET OUTLINE WINDOW FILETYPE
    # ==============================================
    win_execute(outline_win_id, 'setlocal syntax=vim')

    # ==============================================
    # PARSE CALLING BUFFER
    # ==============================================
    var pattern_export = '^\s*export'
    var pattern_def = '^\s*def'

    # Copy the whole calling buffer to a local variable
    # TIP: For debugging use portions of source code and see what
    # happens, e.g. var Outline = getline(23, 98)
    var Outline = getline(1, "$")
    # We add a "#" because parsing the first line is always problematic
    insert(Outline, "# ", 0)

    # Remove docstrings in two steps:
    # 1) replace all the docstrings lines with tmp_string (see below)
    # 2) filter out lines that are not tmp_string

    # # Init
    # var ii = 0
    # var is_docstring = false

    # # Iteration
    # # Most likely the user won't have the value of tmp_string
    # # in any of his python comment or docstrings
    # var tmp_string = "<hshnnTejwqik93la,AMNDNJFJKK3N2MNMAKPD+03mn2nhkalpdpk3nsla>"
    # for item in Outline
    #     if item =~ '.*""".*"""' # Regular expression for finding docstrings
    #         Outline[ii] = tmp_string
    #     elseif item =~ '"""' && item !~ '.*""".*"""'
    #         Outline[ii] = tmp_string
    #         is_docstring = !is_docstring
    #     elseif is_docstring
    #         Outline[ii] = tmp_string
    #     endif
    #     ii = ii + 1
    # endfor

    # Actually remove dosctrings
    # Outline = Outline ->filter("v:val !~ 'tmp_string'")

    # Now you can filter by class, functions and methods.
    # TODO: fix this
    Outline = Outline ->filter("v:val =~ " .. string(pattern_export .. '\|' .. pattern_def))

    # TODO: Add a if you want to show line numbers?
    # TODO: Remove all the text after "(" in def myfunc(bla bla bla ?

    # ==============================================
    # POPULATE WINDOW
    # ==============================================
    setbufline(winbufnr(outline_win_id), 1, Outline)

    return Outline
enddef
