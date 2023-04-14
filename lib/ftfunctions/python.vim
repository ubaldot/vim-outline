vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# It further store the line numbers of the parsed lines
# to have exact match when jumping from the Outline
# window to the caller buffer
# =================================================

export def ParseBuffer(outline_win_id: number): list<number>

    win_execute(outline_win_id, 'setlocal syntax=python')
    var pattern_class = '^class'
    var pattern_def = '^\s*def'
    var pattern_private_def = '^\s*def\s_\{-1,2}'

    # Copy the whole calling buffer to a local variable
    var Outline = getline(1, "$")

    # Remove docstrings in two steps:
    # 1) replace all the docstrings lines with tmp_string (see below)
    # 2) filter out lines that are not tmp_string

    # Init
    var ii = 0
    var is_comment = Outline[ii] =~ '"""' && Outline[ii] !~ '.*""".*"""'

    # Iteration
    # Most likely the user won't have the value of tmp_string
    # in any of his python comment or docstrings
    var tmp_string = "<hshnnTejwqik93la,AMNDNJFJKK3N2MNMAKPD+03mn2nhkalpdpk3nsla>"
    for item in Outline
        if item =~ '.*""".*"""' # Regular expression for finding docstrings
            Outline[ii] = tmp_string
        elseif item =~ '"""' && item !~ '.*""".*"""'
            Outline[ii] = tmp_string
            is_comment = !is_comment
        elseif is_comment
            Outline[ii] = tmp_string
        endif
        ii = ii + 1
    endfor

    # Note that Outline index and line number of the original file
    # match 1-1 being Outline = getlines(1, "$")
    # line_numbers contain the line number of the matches and will be
    # used when you need to jump from the Outline to the caller buffer.
    # TODO: Check if you can do the following with a map()
    var line_numbers = []
    ii = 0
    for item in Outline
        if item =~ pattern_class || item =~ pattern_def
            add(line_numbers, ii + 1)
        endif
        ii = ii + 1
    endfor

    # Actually remove dosctrings
    Outline = Outline ->filter("v:val !~ 'tmp_string'")

    # Now you can filter by class, functions and methods.
    if g:show_private
        Outline = Outline ->filter("v:val =~ " .. string(pattern_class .. '\|' .. pattern_def))
    else
        Outline = Outline ->filter("v:val =~ " .. string(pattern_class .. '\|' .. pattern_def))
            ->filter("v:val !~ " .. string(pattern_private_def))
    endif

    # TODO: Add a if you want to show line numbers?
    # Outline = Outline -> filter('v:val != ' .. string(lnums_regex))

    # TODO: Remove all the text after "(" in def myfunc(bla bla bla ?
    # Outline = Outline -> filter('v:val != "(.*"')

    # Write the outline in the Outline window
    setbufline(winbufnr(outline_win_id), 1, Outline)

    # Outline var may be very large and memory consuming.
    # Let's clean it up
    Outline = []

    # Do we really need to return line_numbers?
    return line_numbers
enddef
