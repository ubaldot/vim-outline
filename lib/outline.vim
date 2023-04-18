vim9script

# ========================================================
# Outline functions
#
# export OutlineToggle()
# export OutlineRefresh()
# export OutlineGoToOutline()
#
# ========================================================

import autoload "./quotes.vim"

# Script variables
var title = ['Go on a line and hit <enter>', 'to jump to definition.', ""]
var Outline = [""] # It does not like [] initialization
var outline_win_id = 0


# Script functions
sign define CurrentItem text=- linehl=CursorLine
def OutlineHighlight(): string
    # Remove any existing sign.
    win_execute(outline_win_id, "sign_unplace('', {'buffer': g:outline_buf_name}) ")

    # Search the item at minimum distance with the cursor (from above)
    # Note that the maximum distance is curr_line - 0 (top) = curr_line
    # Here the are in the caller-buffer coordinates
    var curr_line_nr = line('.')
    var curr_line = getline('.')
    var dist_min = curr_line_nr
    var dist = curr_line_nr
    var target_item = ""

    # OBS! You only find the item at minimum distance,
    # but you don't know if it is a duplicate.
    for item in Outline
        dist = curr_line_nr - search($'\V{item}', 'cnbW')
        # OBS! dist is always >= 0
        if dist <= dist_min
            dist_min = dist
            target_item = item
        endif
    endfor

    # If the search towards the top hit 0, don't highlight anything.
    # Otherwise, if you found a target item, check if there are duplicates,
    # and highlight the correct one.
    if dist_min != curr_line_nr
        # Check if the found target_item is a duplicate starting from the current line
        # and going backwards to line 1  of the current buffer
        var num_duplicates = len(getline(1, '$')[0 : curr_line_nr - 1]
                    \ -> filter($"v:val ==# '{target_item}'"))

        # List of lines where there are duplicates.
        var lines = []
        for ii in range(0, len(Outline) - 1)
          if Outline[ii] ==# target_item
            add(lines, ii)
          endif
        endfor
        var line_nr = lines[num_duplicates - 1] + len(title) + 1

        # Now you can highlight
        setwinvar(win_id2win(outline_win_id), "line_nr", line_nr)
        win_execute(outline_win_id, 'cursor(w:line_nr, 1) | norm! ^')
        win_execute(outline_win_id, 'sign_place(w:line_nr, "", ''CurrentItem'', g:outline_buf_name, {''lnum'': w:line_nr})')
    endif

    if exists('b:CurrentItem')
        # echom b:CurrentItem(target_item)
        return b:CurrentItem(target_item)
    else
        return ""
    endif
enddef


def GoToDefinition()
    var curr_line_nr = max([1, line('.') - len(title)])
    var curr_line = getline('.')
    var counter = len(Outline[0 : curr_line_nr - 1] -> filter($"v:val ==# '{curr_line}'"))

    # TODO: check if you can replace wincmd p with some builtin function
    wincmd p

    # The number of jumps needed are counted from the
    # beginning of the file
    cursor(1, 1)
    for ii in range(counter)
        # TODO This looks for a regular expression not for the literal string! Fix it!
        search($'\V{curr_line}', "W")
    endfor

    # Update highlighting
    win_execute(outline_win_id, 'setlocal modifiable noreadonly')
    OutlineHighlight()
    win_execute(outline_win_id, 'setlocal nomodifiable readonly')
enddef


def OutlineClose()
    # Close the window
    if OutlineIsOpen()
        win_execute(outline_win_id, 'wincmd c')
    endif
enddef


def OutlineIsOpen(): bool
    # -1 if the buffer is not in any window.
    if bufwinid($"^{g:outline_buf_name}$") != -1
        return true
    else
        return false
    endif
enddef


export def OutlineGoToOutline()
    if OutlineIsOpen()
        win_gotoid(bufwinid($"^{g:outline_buf_name}$"))
    endif
enddef


export def OutlineToggle()
    if OutlineIsOpen()
       OutlineClose()
    else
       OutlineOpen()
       OutlineRefresh()
    endif
enddef



def PopulateOutlineWindow()

    # -----------------------------------
    #  Copy the whole buffer
    # -----------------------------------
    # TIP: For debugging use portions of source code and see what
    # happens, e.g. var Outline = getline(23, 98)
    Outline = getline(1, "$")
    # TODO: check the comment string thing
    insert(Outline, &commentstring, 0) # We add a comment line because parsing the first line is always problematic

    # -----------------------------------
    # Pre-process Outline
    # -----------------------------------
    #  OBS! Outline filetype is set here!
    # Parse the buffer and populate the window
    if exists('b:PreProcessOutline')
        # b:PreProcessOutline is a FuncRef
        Outline = b:PreProcessOutline(outline_win_id, Outline)
    endif

    # -----------------------------------
    # Filter user request
    # -----------------------------------
    # echom "filetype:" .. &filetype
    if exists('b:FilterOutline')
        Outline = b:FilterOutline(Outline)
    endif

    # Default: if filetype is not supported, then clean up the Outline
    if !exists('b:PreProcessOutline') && !exists('b:FilterOutline')
        win_execute(outline_win_id, 'setlocal syntax=')
        var idx = rand(srand()) % len(quotes.quotes)
        Outline = quotes.quotes[idx]
    endif

    # ----------------------------------------------
    # Actually populate the window
    # ----------------------------------------------
    setbufline(winbufnr(outline_win_id), len(title) + 1, Outline)
    # setbufline(winbufnr(outline_win_id), 1, Outline)
    win_execute(outline_win_id, 'setlocal nomodifiable readonly')

    # Highlight
    OutlineHighlight()

enddef

export def OutlineRefresh()
    # TODO Lock window content. Consider using w:buffer OBS! NERD tree don't have this feature!
    # If outline is open and I am not on that.
    if OutlineIsOpen() && bufwinid(bufnr()) != outline_win_id

        # -----------------------------------------
        # CLEAN OUTLINE AND UNLOCK OUTLINE BUFFER
        # -----------------------------------------
        win_execute(outline_win_id, 'setlocal modifiable noreadonly')
        deletebufline(winbufnr(outline_win_id), len(title) + 1, line('$', outline_win_id))

        # -----------------------------------------
        # POPULATE THE EMPTY WIN.
        # -----------------------------------------
        PopulateOutlineWindow()
    endif
enddef


def OutlineOpen(): number
    # Create empty win from current position
    win_execute(win_getid(), $'vertical split {g:outline_buf_name}')

    # Set stuff in the newly created window
    outline_win_id = win_findbuf(bufnr('$'))[0]
    win_execute(outline_win_id, 'wincmd L')
    win_execute(outline_win_id, $'vertical resize {g:outline_win_size}')
    win_execute(outline_win_id,
        \    'setlocal buftype=nofile bufhidden=wipe
        \ nobuflisted noswapfile nowrap
        \ nonumber equalalways winfixwidth')

    # Set few w: local variables
    # Let the Outline window to access this script by passing a function
    setwinvar(win_id2win(outline_win_id), "GoToDefinition", GoToDefinition) # Passing a function
    win_execute(outline_win_id, 'nnoremap <buffer> <silent> <enter> :call w:GoToDefinition()<cr>')
    if has("gui")
        win_execute(outline_win_id, 'nnoremap <buffer> <silent> <2-LeftMouse> :call w:GoToDefinition()<cr>')
    endif

    # Set title
    setbufline(winbufnr(outline_win_id), 1, title)
    # Title does not follow syntax highlight but it is in black.
    win_execute(outline_win_id, 'matchaddpos(''Terminal'', range(1, len(title)))')

    # -----------------------------------------
    # ADD SOME SUGAR
    # -----------------------------------------
    win_execute(outline_win_id, 'nnoremap <buffer> j j^')
    win_execute(outline_win_id, 'nnoremap <buffer> k k^')
    win_execute(outline_win_id, 'nnoremap <buffer> <down> <down>^')
    win_execute(outline_win_id, 'nnoremap <buffer> <up> <up>^')
    win_execute(outline_win_id, 'cursor(len(title) + 1, 1)')

    return outline_win_id
enddef



augroup Outline_autochange
    au!
    # If Outline is opened and you are not on the Outline window itself, then update.
    autocmd BufEnter * if OutlineIsOpen() && bufwinid(bufnr()) != outline_win_id | OutlineRefresh() | endif
    # autocmd! BufWinLeave outline#PyOutlineClose()
augroup END
