vim9script

# ========================================================
# Outline functions
# ========================================================


# Script variables
var title = ["Go on a line and hit <enter>", "to jump to definition.", ""]

def g:PyFindDef(line_numbers: list<number>)
    # You should always go on the right spot
    # by construction. See how line_numbers is built.
    echo len(title)
    var idx = max([0, line('.') - len(title) - 1])
    # TODO: go to ^
    wincmd p
    # win_execute(win_getid(), 'wincmd p')
    cursor(line_numbers[idx], 1)

    # search(line, "w")
enddef


export def g:PyOutlineClose()
    var outline_win_id = bufwinid("^" .. g:outline_buf_name .. "$")
    # echo "ccc"

    if outline#PyOutlineIsOpen() != -1
        win_gotoid(outline#PyOutlineIsOpen())
        exe ":close"
    endif

    # Throw away the old Outline (that was a scratch buffer)
    # outline_win_id =
    if bufexists(bufnr("^" .. g:outline_buf_name .. "$"))
       # echom "Outline buffer deleted."
       exe "bw " .. bufnr("^" .. g:outline_buf_name .. "$")
    endif
enddef



export def g:PyOutlineIsOpen(): number
    # Return win_ID if open, -1 otherwise.
    return bufwinid("^" .. g:outline_buf_name .. "$")
enddef



export def g:PyOutlineToggle(show_private: bool)
    if outline#PyOutlineIsOpen() != -1
        outline#PyOutlineClose()
    else
        outline#PyOutlineOpen(show_private)
    endif
enddef

export def g:PyOutlineParseBufferFallback(outline_win_id: number): list<number>
    echo "In the fallback function"
    return []
enddef

export def g:PyOutlineOpen(show_private: bool = 1): number
    # Return the win ID or -1 if &filetype is not python.
    # TODO Refresh automatically
    # TODO Lock window content. Consider using w:buffer OBS! NERD tree don't have this feature!
    if &filetype != "python"
        echo "Filetype is not python!"
        outline#PyOutlineClose()
        return -1
    endif

    # Close previous Outline view (if any)
    outline#PyOutlineClose()

    # CREATE EMPTY WIN.
    # Create empty win from current position
    win_execute(win_getid(), 'wincmd n')

    # Set stuff in the newly created window
    var outline_win_nr = winnr('$')
    var outline_win_id = win_getid(outline_win_nr)
    win_execute(outline_win_id, 'wincmd L')
    win_execute(outline_win_id, 'vertical resize ' .. g:outline_win_size)
    win_execute(outline_win_id, 'file ' .. g:outline_buf_name)
    win_execute(outline_win_id,
        \    'setlocal buftype=nofile bufhidden=hide
        \ nobuflisted noswapfile nowrap
        \ nonumber equalalways winfixwidth')



    ## ======== This shall be file dependent BEGIN ===============
    ## TODO: create a function in ftplugin: # https://vi.stackexchange.com/questions/11231/is-it-possible-to-create-a-function-with-the-same-name-for-different-filetypes
    ##
    ## Input should be the window ID
    ## Output the line numbers for the jumps
    ##
    #win_execute(outline_win_id, 'setlocal syntax=python')
    ## var pattern_blank_line = '^\s*$'
    ## var pattern_empty_line = '^$'
    ## var pattern_docstrings1 = '^\s*\w*' # a docstring may start with r""" ...
    ## # var pattern_docstrings2 = '"""\_.\{-}"""$' # Everything inside between two consecutive """ """
    ## var pattern_docstrings2 = '"""\.*"""$' # Everything inside between two consecutive """ """
    #var pattern_docstrings_gtp = '\v([rf]?["'']{3})(\_.{-})(\1)'
    #var pattern_class = '^class'
    #var pattern_def = '^\s*def'
    #var pattern_private_def = '^\s*def\s_\{-1,2}'


    #var Outline = getline(1, "$")
    ## Remove docstrings in two steps:
    ## 1) replace all the docstrings lines with tmp_string
    ## 2) filter out lines that are not tmp_string
    ##
    ## Init
    #var ii = 0
    #var is_comment = Outline[ii] =~ '"""' && Outline[ii] !~ '.*""".*"""'

    ## Iteration
    #var tmp_string = "<vim-removed>"
    #for item in Outline
    #    # echo is_comment
    #    if item =~ '.*""".*"""'
    #        Outline[ii] = tmp_string
    #    elseif item =~ '"""' && item !~ '.*""".*"""'
    #        Outline[ii] = tmp_string
    #        is_comment = !is_comment
    #    elseif is_comment
    #        Outline[ii] = tmp_string
    #    endif
    #    ii = ii + 1
    #endfor

    ## Note that Outline idx - line number of the original file
    ## match 1-1 being Outline = getlines(1, "$")
    ## Check if you can do it with map()
    #var line_numbers = []
    #ii = 0
    #for item in Outline
    #    if item =~ pattern_class || item =~ pattern_def
    #        add(line_numbers, ii + 1)
    #    endif
    #    ii = ii + 1
    #endfor

    ## Actually remove dosctrings
    #Outline = Outline ->filter("v:val !~ 'tmp_string'")

    ## Now you can filter by class, functions and methods.
    #if g:show_private
    #    Outline = Outline ->filter("v:val =~ " .. string(pattern_class .. '\|' .. pattern_def))
    #else
    #    Outline = Outline ->filter("v:val =~ " .. string(pattern_class .. '\|' .. pattern_def))
    #        ->filter("v:val !~ " .. string(pattern_private_def))
    #endif

    ## Add a if you want to show line numbers
    ## Outline = Outline -> filter('v:val != ' .. string(lnums_regex))

    ## Remove all the text after "(" in def myfunc(bla bla bla
    ## Outline = Outline -> filter('v:val != "(.*"')

    ## echo Outline
    #setbufline(g:outline_buf_name, 1, Outline)

    ## Return line numbers

    # ======== This shall be file dependent END ==============

    var line_numbers = outline#PyOutlineParseBuffer(outline_win_id)
    # FINAL TOUCH
    # TODO: keep size independently of the opened windows
    # Set instructions, append after lnum 0
    appendbufline(g:outline_buf_name, 0, title)
    cursor(len(title) + 1, 1)

    # After write, set it to do non-modifiable
    win_execute(outline_win_id, 'setlocal nomodifiable readonly')
    setwinvar(win_id2win(outline_win_id), "line_numbers", line_numbers)
    win_execute(outline_win_id, 'nnoremap <buffer> <enter> :call g:PyFindDef(w:line_numbers)<cr>')
    return outline_win_id
enddef


augroup Outline_parse_buffer
    au!
    autocmd BufRead,BufNewFile *
        \ if !exists('b:CurrentFunctionName') |
        \   b:CurrentFunctionName = function('<SID>outline#PyOutlineParseBufferFallback') |
        \ endif
augroup END

augroup Outline_autochange
    au!
    autocmd BufWinEnter *.py if outline#PyOutlineIsOpen() != -1
                \| outline#PyOutlineOpen(g:show_private) | endif
    autocmd! BufWinLeave outline#PyOutlineClose()
augroup END
