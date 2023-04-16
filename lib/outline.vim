vim9script

# ========================================================
# Outline functions
#
# export OutlineToggle()
# export OutlineRefresh()
#
# ========================================================

# Script variables
var title = ['Go on a line and hit <enter>', 'to jump to definition.', ""]
var Outline = [""] # It does not like [] initialization

# Script functions
#
def HighlightLine()
    echo "TBD!"
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
        # the \V is needed to consider literal string and not regex
        search($'\V{curr_line}', "W")
    endfor
enddef


def OutlineClose()
    # In 2 steps:
        # 1. Close the window,
        # 2. wipeout the buffer
    # var outline_win_id = bufwinid($"^{g:outline_buf_name}$")

    # Close the window
    if OutlineIsOpen() != -1
        win_gotoid(OutlineIsOpen())
        # TODO check if you can replace the Ex command with a builtin function
        exe ":close"
    endif

    # Throw away the old Outline (that was a scratch buffer)
    if bufexists(bufnr($"^{g:outline_buf_name}$"))
       echom "Outline buffer deleted."
       exe "bw " .. bufnr($"^{g:outline_buf_name}$")
    endif
enddef



def OutlineIsOpen(): number
    # Return win_ID if open, -1 otherwise.
    return bufwinid($"^{g:outline_buf_name}$")
enddef

export def OutlineToggle()
    if OutlineIsOpen() != -1
       OutlineClose()
    else
       OutlineFill(OutlineCreateEmptyWindow())
    endif
enddef

export def OutlineRefresh()
    var outline_win_id = OutlineIsOpen()
    if outline_win_id != -1
        win_execute(outline_win_id, 'setlocal modifiable noreadonly')
        deletebufline(winbufnr(outline_win_id), 1, line('$', outline_win_id))
        OutlineFill(outline_win_id)
    endif
enddef

def PopulateOutlineWindowFallback(outline_win_id: number): list<string>
    echo "In the fallback function! :D"
    return []
enddef

def OutlineCreateEmptyWindow(): number
    # =========================================
    # CREATE EMPTY WIN.
    # =========================================
    # Create empty win from current position
    win_execute(win_getid(), 'wincmd n')

    # Set stuff in the newly created window
    var outline_win_nr = winnr('$')
    var outline_win_id = win_getid(outline_win_nr)
    win_execute(outline_win_id, 'wincmd L')
    win_execute(outline_win_id, $'vertical resize {g:outline_win_size}')
    win_execute(outline_win_id, $'file {g:outline_buf_name}')
    win_execute(outline_win_id,
        \    'setlocal buftype=nofile bufhidden=hide
        \ nobuflisted noswapfile nowrap
        \ nonumber equalalways winfixwidth')
    return outline_win_id
enddef


def OutlineFill(outline_win_id: number)
    # Return the win ID or -1 if &filetype is not python.
    # TODO Refresh automatically
    # TODO Lock window content. Consider using w:buffer OBS! NERD tree don't have this feature!
    # Close previous Outline view (if any)
    # OutlineClose()

    # =========================================
    # POPULATE THE EMPTY WIN.
    # =========================================
    # Parse the buffer and populate the window
    if exists('b:PopulateOutlineWindow')
        Outline = b:PopulateOutlineWindow(outline_win_id, g:outline_options[&filetype]) # b:PopulateOutlineWindow is a FuncRef
    else
        Outline = PopulateOutlineWindowFallback(outline_win_id)
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

    # Add some sugar
    # TODO: how to remove syntax in the title
    win_execute(outline_win_id, 'nnoremap <buffer> j j^')
    win_execute(outline_win_id, 'nnoremap <buffer> k k^')
    win_execute(outline_win_id, 'nnoremap <buffer> <down> <down>^')
    win_execute(outline_win_id, 'nnoremap <buffer> <up> <up>^')
    win_execute(outline_win_id, 'cursor(len(title) + 1, 1)')
enddef


# augroup Outline_autochange
#     au!
#     autocmd BufWinEnter *.py if outline#PyOutlineIsOpen() != -1
#                 \| outline#PyOutlineOpen(g:outline_python_show_private) | endif
#     autocmd! BufWinLeave outline#PyOutlineClose()
# augroup END
