vim9script

# ========================================================
# Outline functions
#
# export OutlineToggle()
# export OutlineRefresh()
# export OutlineGoToOutline()
#
# ========================================================

# Script variables
var title = ['Go on a line and hit <enter>', 'to jump to definition.', ""]
var Outline = [""] # It does not like [] initialization
var outline_win_id = 0

# Script functions
# sign define CurrentFunction text=- linehl=CursorLine
def OutlineHighlight(): string
    var curr_line = line('.')
    var dist_min = line('$') + 1
    var dist = dist_min
    var target_item = ""

    # TODO Adjust better: when the search hit the top don't highlight anything
    for item in Outline
        dist = curr_line - search($'\V{item}', 'cnbW')
        # OBS! Distance is always >= 0
        if dist <= dist_min
            dist_min = dist
            target_item = item
        endif
    endfor

    # If the search didn't finally hit the top
    var line_nr = index(Outline, target_item) + len(title) + 1
    setwinvar(win_id2win(outline_win_id), "line_nr", line_nr)
    # TODO Shall you define the sign every time?!
    win_execute(outline_win_id, "sign_define('CurrentFunction', {'text': '-', 'linehl': 'CursorLine'})")
    win_execute(outline_win_id, "sign_unplace('', {'buffer': g:outline_buf_name}) ")
    win_execute(outline_win_id, 'sign_place(w:line_nr, "", ''CurrentFunction'', g:outline_buf_name, {''lnum'': w:line_nr})')
    # TODO: format the return type better, depending on the filtetype.
    return target_item
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
    # In 2 steps:
        # 1. Close the window,
        # 2. wipeout the buffer

    # Close the window
    if OutlineIsOpen()
        win_execute(outline_win_id, 'wincmd c')
    endif

    # Throw away the old Outline (that was a scratch buffer)
    if bufexists(bufnr($"^{g:outline_buf_name}$"))
       exe "bw! " .. bufnr($"^{g:outline_buf_name}$")
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

export def OutlineRefresh()
    # TODO Lock window content. Consider using w:buffer OBS! NERD tree don't have this feature!
    # If outline is open and I am not on that.
    if OutlineIsOpen() && bufwinid(bufnr()) != outline_win_id

        # =========================================
        # CLEAN OUTLINE AND UNLOCK OUTLINE BUFFER
        # =========================================
        win_execute(outline_win_id, 'setlocal modifiable noreadonly')
        deletebufline(winbufnr(outline_win_id), 1, line('$', outline_win_id))

        # =========================================
        # POPULATE THE EMPTY WIN.
        # =========================================
        # Parse the buffer and populate the window
        if exists('b:PopulateOutlineWindow')
            Outline = b:PopulateOutlineWindow(outline_win_id, g:outline_options[&filetype]) # b:PopulateOutlineWindow is a FuncRef
        else
            Outline = []
            echo "I cannot outline buffers of this filetype."
        endif


        # =========================================
        #  A FINAL TOUCH.
        # =========================================
        # Set title, append after lnum 0
        appendbufline(winbufnr(outline_win_id), 0, title)

        # After having populated the Outline, set it to do non-modifiable
        win_execute(outline_win_id, 'setlocal nomodifiable readonly')

        # Set few w: local variables
        # Let the Outline window to access this script by passing a function
        setwinvar(win_id2win(outline_win_id), "GoToDefinition", GoToDefinition) # Passing a function
        win_execute(outline_win_id, 'nnoremap <buffer> <silent> <enter> :call w:GoToDefinition()<cr>')
        if has("gui")
            win_execute(outline_win_id, 'nnoremap <buffer> <silent> <2-LeftMouse> :call w:GoToDefinition()<cr>')
        endif

        # =========================================
        # ADD SOME SUGAR
        # =========================================
        # TODO: how to remove syntax in the title
        win_execute(outline_win_id, 'nnoremap <buffer> j j^')
        win_execute(outline_win_id, 'nnoremap <buffer> k k^')
        win_execute(outline_win_id, 'nnoremap <buffer> <down> <down>^')
        win_execute(outline_win_id, 'nnoremap <buffer> <up> <up>^')
        win_execute(outline_win_id, 'cursor(len(title) + 1, 1)')

        # Highlight
        OutlineHighlight()
    endif
enddef


def OutlineOpen(): number

    # Create empty win from current position
    win_execute(win_getid(), 'wincmd n')

    # Set stuff in the newly created window
    # The last created buffer should be [No name] relative to wincd n of above
    outline_win_id = win_findbuf(bufnr('$'))[0]
    # var outline_win_id = win_getid(outline_win_nr)
    win_execute(outline_win_id, 'wincmd L')
    win_execute(outline_win_id, $'vertical resize {g:outline_win_size}')
    win_execute(outline_win_id, $'file {g:outline_buf_name}')
    win_execute(outline_win_id,
        \    'setlocal buftype=nofile bufhidden=hide
        \ nobuflisted noswapfile nowrap
        \ nonumber equalalways winfixwidth')

    return outline_win_id
enddef

augroup Outline_autochange
    au!
    # If Outline is opened and you are not on the Outline window itself, then update.
    autocmd BufEnter * if OutlineIsOpen() && bufwinid(bufnr()) != outline_win_id | OutlineRefresh() | endif
    # autocmd! BufWinLeave outline#PyOutlineClose()
augroup END
