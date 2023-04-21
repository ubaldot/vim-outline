vim9script

# ========================================
# Everything happens in the current buffer
# with the exception of GoToDefinition()
# ========================================

# Imports
import autoload "./quotes.vim"

# Script variables
var title = ['Go on a line and hit <enter>', 'to jump to definition.', ""]
var Outline = [""] # It does not like [] initialization
var outline_win_id = 0

# Script functions
sign define CurrentItem text=- linehl=CursorLine
def Highlight(target_item: string)

    # Enable for modification
    win_execute(outline_win_id, 'setlocal modifiable noreadonly')

    # Remove any existing sign.
    win_execute(outline_win_id, "sign_unplace('', {'buffer': g:outline_buf_name}) ")

    # echom "target_item is: " .. target_item

    # If the found item is "", then don't highlight anything.
    # Otherwise, if you found a target item, check if there are duplicates,
    # and highlight the correct one.
    if target_item !=# ""

        # Check if the found target_item is a duplicate starting from the current line
        # and going backwards to line 1  of the current buffer
        var curr_line_nr = line('.')
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
    # Lock window modifications.
    win_execute(outline_win_id, 'setlocal nomodifiable readonly')
enddef

def FindClosestItem(): string

    # Search the item at minimum distance with the cursor (from above)
    # Note that the maximum distance is curr_line - 0 (top) = curr_line
    # Here the are in the caller-buffer coordinates
    var curr_line_nr = line('.')
    # echo "curr_line_nr: " .. curr_line_nr
    var curr_line = getline('.')
    var dist_min = curr_line_nr
    var dist = curr_line_nr
    var found_item = ""

    # OBS! You only find the item at minimum distance,
    # but you don't know if it is a duplicate.
    for item in Outline
        dist = curr_line_nr - search($'\V{item}', 'cnbW')
        # OBS! dist is always >= 0
        if dist <= dist_min
            dist_min = dist
            found_item = item
        endif
    endfor

    # If the search towards the top hit 0, return "".
    # Otherwise, return found_item.
    if dist_min != curr_line_nr
        return found_item
    else
        return ""
    endif
enddef


def GoToDefinition()
    # Search item in the Outline side-window first!
    var curr_line_nr = max([1, line('.') - len(title)])
    var curr_line = getline('.')
    var counter = len(Outline[0 : curr_line_nr - 1]
                \ -> filter($"v:val ==# '{curr_line}'"))

    # TODO: check if you can replace wincmd p with some builtin function
    # Obs! This trigger the BufEnter event!
    # This means that there will be an immediate (wrong) RefreshWindow()
    wincmd p

    # The number of jumps needed are counted from the
    # beginning of the file
    cursor(1, 1)
    for ii in range(counter)
        # TODO This looks for a regular expression not for the literal string! Fix it!
        search($'\V{curr_line}', "W")
    endfor
    # You moved the cursor, so to be correct you must RefreshWindow() again
    RefreshWindow()
enddef


export def GoToOutline()
    if IsOpen()
        win_gotoid(bufwinid($"^{g:outline_buf_name}$"))
    endif
enddef


def Close()
    # Close the window
    if IsOpen()
        win_execute(outline_win_id, 'wincmd c')
    endif
enddef


def Open(): number
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


def IsOpen(): bool
    # -1 if the buffer is not in any window.
    if bufwinid($"^{g:outline_buf_name}$") != -1
        return true
    else
        return false
    endif
enddef


export def Toggle()
    if IsOpen()
       Close()
    else
       Open()
       RefreshWindow()
    endif
enddef


def UpdateOutline()
    # This function only update the Outline variable.

    # -----------------------------------
    #  Copy the whole buffer
    # -----------------------------------
    # TIP: For debugging use portions of source code and see what
    # happens, e.g. var Outline = getline(23, 98)
    Outline = getline(1, "$")
    # TODO: check the &commentstring thing here
    # We add a comment line because parsing the first line is always problematic
    insert(Outline, &commentstring, 0)

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
    if exists('b:FilterOutline')
        Outline = b:FilterOutline(Outline)
    endif

    # Default: if filetype is not supported, then clean up the Outline
    if !exists('b:PreProcessOutline') && !exists('b:FilterOutline')
        win_execute(outline_win_id, 'setlocal syntax=')
        var idx = rand(srand()) % len(quotes.quotes)
        Outline = quotes.quotes[idx]
    endif
enddef


export def RefreshWindow(): string
    # The function actually returns the closest item AND it
    # refresh the side-window if needed.
    # We place it here to do not have to export another dedicated
    # function e.g. FindClosestItem().
    # Also, from a user perspective, the Refresh include a bit of
    # everything.

    UpdateOutline()
    # Get target item
    const target_item = FindClosestItem()

    # TODO Lock window content. Consider using w:buffer OBS! NERD tree don't have this feature!
    # If Outline is open and I am not on Outline window.
    if IsOpen() && bufwinid(bufnr()) != outline_win_id
        # echom "LINE: " .. line('.')
        # -----------------------------------------
        # clean outline and unlock outline buffer
        # -----------------------------------------
        win_execute(outline_win_id, 'setlocal modifiable noreadonly')
        deletebufline(winbufnr(outline_win_id), len(title) + 1, line('$', outline_win_id))

        # ----------------------------------------------
        # Actually populate the window
        # ----------------------------------------------
        setbufline(winbufnr(outline_win_id), len(title) + 1, Outline)
        win_execute(outline_win_id, 'setlocal nomodifiable readonly')

        # Highlight
        if g:outline_enable_highlight
            Highlight(target_item)
        endif
    endif
    # Return the cleaned target_item
    # TODO make it work with vim-airline
    if exists('b:CurrentItem')
        # echo b:CurrentItem(FindClosestItem())
        return b:CurrentItem(FindClosestItem())
    else
        return ""
    endif
enddef


augroup Outline_autochange
    autocmd!
    # If the entered buffer is not the Outline window, then RefreshWindow.
    # TODO: changing buffer with mouse it is tricky because it triggers two events: BufEnter + CursorMove
    # Hence, you miss the current line when you enter the buffer.
    autocmd BufEnter *  if bufwinid(bufnr()) != outline_win_id | :call RefreshWindow() | endif
    # autocmd BufEnter * :echo line('.')
augroup END
