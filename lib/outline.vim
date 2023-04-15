vim9script

# ========================================================
# Outline functions
#
# export only OutlineToggle(show_private: bool)
#
# ========================================================

# Script variables
var title = ['Go on a line and hit <enter>', 'to jump to definition.', ""]

# TODO: add a sign function for Outline
# Script functions
#
def HighlightLine()
    echo "TBD!"
enddef


def GoToDefinition(Outline: list<string>)
    # You should always go on the right spot
    # by construction. See how line_numbers is built.
    var line_nr = max([1, line('.') - len(title)])
    var line = getline('.')
    var counter = 0
    var start_pos = 0

    # echom Outline[line_nr - 1]
    # echom line
    # echom line_nr
    # echom  $"Found at pos: {index(Outline[0 : line_nr - 1], line)}"
    while start_pos < line_nr - 1
        counter += 1
        start_pos = index(Outline[start_pos : line_nr - 1], line)
        if start_pos == -1
            start_pos = line('$') + 1
        endif
    endwhile
    # echo counter
    # var idx = max([0, line('.') - len(title) - 1])
    wincmd p
    for ii in range(counter)
        # echom substitute(line, '(.*', "(", "")
        # Hack for removing everything after ( in a function signature,
        # otherwise search() may not like it
        search(substitute(line, '(.*', "(", ""), "cw")
    endfor
    # win_execute(win_getid(), 'wincmd p')
    # cursor(line_numbers[idx], 1)
    # TODO: check if you can replace Ex commands with builin functions
    # normal ^
enddef


def OutlineClose()
    # In 2 steps:
        # 1. Close the window,
        # 2. wipeout the buffer
    var outline_win_id = bufwinid($"^{g:outline_buf_name}$")

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

export def OutlineToggle(show_private: bool)
    if OutlineIsOpen() != -1
       OutlineClose()
    else
       OutlineOpen(show_private)
    endif
enddef

def PopulateOutlineWindowFallback(outline_win_id: number): list<string>
    echo "In the fallback function! :D"
    return []
enddef

def OutlineOpen(show_private: bool = 1): number
    # Return the win ID or -1 if &filetype is not python.
    # TODO Remove the show private dependency
    # TODO Refresh automatically
    # TODO Lock window content. Consider using w:buffer OBS! NERD tree don't have this feature!
    # Close previous Outline view (if any)
    OutlineClose()

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


    # =========================================
    # POPULATE THE EMPTY WIN.
    # =========================================
    # Parse the buffer and populate the window
    var Outline = [""] # It does not like [] initialization
    if exists('b:PopulateOutlineWindow')
        Outline = b:PopulateOutlineWindow(outline_win_id) # b:PopulateOutlineWindow is a FuncRef
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
    setwinvar(win_id2win(outline_win_id), "Outline", Outline)
    setwinvar(win_id2win(outline_win_id), "GoToDefinition", GoToDefinition) # Passing a function
    win_execute(outline_win_id, 'nnoremap <buffer> <silent> <enter> :call w:GoToDefinition(w:Outline)<cr>')

    # Add some sugar
    # TODO: how to remove syntax in the title
    win_execute(outline_win_id, 'nnoremap <buffer> j j^')
    win_execute(outline_win_id, 'nnoremap <buffer> k k^')
    win_execute(outline_win_id, 'nnoremap <buffer> <down> <down>^')
    win_execute(outline_win_id, 'nnoremap <buffer> <up> <up>^')
    win_execute(outline_win_id, 'cursor(len(title) + 1, 1)')
    return outline_win_id
enddef


# augroup Outline_autochange
#     au!
#     autocmd BufWinEnter *.py if outline#PyOutlineIsOpen() != -1
#                 \| outline#PyOutlineOpen(g:outline_python_show_private) | endif
#     autocmd! BufWinLeave outline#PyOutlineClose()
# augroup END
