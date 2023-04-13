vim9script

# ======== This shall be file dependent BEGIN ===============



# TODO: create a function in ftplugin: # https://vi.stackexchange.com/questions/11231/is-it-possible-to-create-a-function-with-the-same-name-for-different-filetypes
#
# Input should be the window ID
# Output the line numbers for the jumps

def PyOutlineParseBuffer(outline_win_id: number): list<number>

    win_execute(outline_win_id, 'setlocal syntax=python')
    # var pattern_blank_line = '^\s*$'
    # var pattern_empty_line = '^$'
    # var pattern_docstrings1 = '^\s*\w*' # a docstring may start with r""" ...
    # # var pattern_docstrings2 = '"""\_.\{-}"""$' # Everything inside between two consecutive """ """
    # var pattern_docstrings2 = '"""\.*"""$' # Everything inside between two consecutive """ """
    var pattern_docstrings_gtp = '\v([rf]?["'']{3})(\_.{-})(\1)'
    var pattern_class = '^class'
    var pattern_def = '^\s*def'
    var pattern_private_def = '^\s*def\s_\{-1,2}'


    var Outline = getline(1, "$")
    # Remove docstrings in two steps:
    # 1) replace all the docstrings lines with tmp_string
    # 2) filter out lines that are not tmp_string
    #
    # Init
    var ii = 0
    var is_comment = Outline[ii] =~ '"""' && Outline[ii] !~ '.*""".*"""'

    # Iteration
    var tmp_string = "<vim-removed>"
    for item in Outline
        # echo is_comment
        if item =~ '.*""".*"""'
            Outline[ii] = tmp_string
        elseif item =~ '"""' && item !~ '.*""".*"""'
            Outline[ii] = tmp_string
            is_comment = !is_comment
        elseif is_comment
            Outline[ii] = tmp_string
        endif
        ii = ii + 1
    endfor

    # Note that Outline idx - line number of the original file
    # match 1-1 being Outline = getlines(1, "$")
    # Check if you can do it with map()
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

    # Add a if you want to show line numbers
    # Outline = Outline -> filter('v:val != ' .. string(lnums_regex))

    # Remove all the text after "(" in def myfunc(bla bla bla
    # Outline = Outline -> filter('v:val != "(.*"')

    # echo Outline
        setbufline(g:outline_buf_name, 1, Outline)

    return line numbers
enddef

# ======== This shall be file dependent END ==============
#
b:PyOutlineParseBuffer = function('<SID>PyOutlineParseBuffer')
