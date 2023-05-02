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

sign define CurrentItem linehl=CursorLine

# Script functions
def Locate(target_item: string)
    # Highlight target_item (aka closest item) in the outline window
    win_execute(outline_win_id, 'setlocal modifiable noreadonly')
    win_execute(outline_win_id, "sign_unplace('', {'buffer':
                \ g:outline_buf_name}) ")

    # If you have a valid target_item, then check if there are duplicates,
    # and highlight the correct one.
    if target_item !=# ""
        # Check first if the found target_item is a duplicate starting from
        # the current line and going backwards to line 1 in the current
        # buffer.
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

        # Now you know what you should highlight
        setwinvar(win_id2win(outline_win_id), "line_nr", line_nr)
        win_execute(outline_win_id, 'cursor(w:line_nr, 1) | norm! ^')
        win_execute(outline_win_id, 'sign_place(w:line_nr, "",
                    \ ''CurrentItem'', g:outline_buf_name, {''lnum'':
                    \ w:line_nr})')
    endif
    # Lock window
    win_execute(outline_win_id, 'setlocal nomodifiable readonly')
enddef

def FindClosestItem(): string
    # Search the item at minimum distance with the cursor (from above)
    # Note that the maximum distance is curr_line - 0 = curr_line
    # Here we are in the caller-buffer coordinates
    var curr_line_nr = line('.')
    var curr_line = getline('.')
    var dist_min = curr_line_nr
    var dist = curr_line_nr
    var found_item = ""

    # OBS! You only find the item at minimum distance,
    # but you don't know if there is any duplicate of such an item.
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
    # In two steps:
    # 1. Search selected item in the Outline (including duplicates),
    var curr_line_nr = max([1, line('.') - len(title)])
    var target_item = getline('.')
    # counter keeps track of the number of duplicated until this line.
    var counter = len(Outline[0 : curr_line_nr - 1]
                \ -> filter($"v:val ==# '{target_item}'"))

    # 2. Jump back to the main buffer and search for the selected item.
    # TODO: check if you can replace wincmd p with some builtin function
    wincmd p
    # The number of jumps needed to reach the target item are counted from the
    # beginning of the file
    cursor(1, 1)
    for ii in range(counter)
        # TODO This looks for a regular expression not for the literal string!
        search($'\V{target_item}', "W")
    endfor

    if !g:outline_autoclose
        Locate(target_item)
    endif
enddef


export def GoToOutline()
    if IsOpen()
        win_gotoid(bufwinid($"^{g:outline_buf_name}$"))
    endif
enddef


def Close()
    if IsOpen()
        wincmd p
        win_execute(outline_win_id, 'wincmd c')
        # In case there are erroneously other Outline windows open
        for wind in win_findbuf(bufnr($'^{g:outline_buf_name}$'))
            win_execute(wind, 'wincmd c')
        endfor
    endif
enddef


def Open(): number
    # Create empty win from current buffer and give it a name
    win_execute(win_getid(), $'vertical split {g:outline_buf_name}')
    outline_win_id = win_findbuf(bufnr('$'))[0]

    # Set some stuff in the newly created window
    win_execute(outline_win_id, 'wincmd L')
    win_execute(outline_win_id, $'vertical resize {g:outline_win_size}')
    win_execute(outline_win_id,
                \    'setlocal buftype=nofile bufhidden=wipe
                \ nobuflisted noswapfile nowrap
                \ nonumber norelativenumber winfixwidth')

    # Set few w: local variables
    # Let the Outline window to access this script by passing a function
    setwinvar(win_id2win(outline_win_id), "GoToDefinition", GoToDefinition)
    win_execute(outline_win_id, 'nnoremap <buffer> <silent> <enter> :call
                \ w:GoToDefinition()<cr>')
    if has("gui")
        win_execute(outline_win_id, 'nnoremap <buffer> <silent> <2-LeftMouse>
                    \ :call w:GoToDefinition()<cr>')
    endif

    # Set title
    setbufline(winbufnr(outline_win_id), 1, title)
    win_execute(outline_win_id, 'matchaddpos(''Question'',
                \ range(1, len(title)))')

    # Add some sugar
    win_execute(outline_win_id, 'nnoremap <buffer> j j^')
    win_execute(outline_win_id, 'nnoremap <buffer> k k^')
    win_execute(outline_win_id, 'nnoremap <buffer> <down> <down>^')
    win_execute(outline_win_id, 'nnoremap <buffer> <up> <up>^')
    win_execute(outline_win_id, 'cursor(len(title) + 1, 1)')

    return outline_win_id
enddef

def IsOpen(): bool
    if win_id2win(outline_win_id) > 0
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
        GoToOutline()
    endif
enddef


def UpdateOutline(): string
    # This function only update the Outline script variable, even if the
    # outline window is closed.
    # If the current buffer is the outline itself then it does not make sense
    # to update the outline.

    # If supported filetype
    if has_key(g:outline_include_before_exclude, &filetype)
                \ && bufnr() != winbufnr(outline_win_id)
        # -----------------------------------
        #  Copy the whole buffer
        # -----------------------------------
        # TIP: For debugging use portions of source code and see what
        # happens, e.g. var Outline = getline(23, 98)
        Outline = getline(1, "$")
        # We add a comment line because parsing the first line is always
        # problematic
        insert(Outline, &commentstring, 0)

        # -----------------------------------
        # Pre-process Outline
        # -----------------------------------
        # User-defined pre-process function
        # TODO Is it better to call it after the internal pre-process?
        if exists('b:OutlinePreProcess') &&
                index(keys(g:outline_include_before_exclude), &filetype) != -1
            # b:PreProcessOutline is a Funcref
            Outline = b:OutlinePreProcess(Outline)
        endif

        # Parse the buffer and populate the window
        if exists('b:OutlinePreProcessInternal')
            # b:PreProcessOutline is a Funcref
            Outline = b:OutlinePreProcessInternal(Outline)
        endif


        # -----------------------------------
        # Filter user request
        # -----------------------------------
        if exists('b:FilterOutline')
            Outline = b:FilterOutline(Outline)
        endif

        # TODO make it work with vim-airline
        return b:CurrentItem(FindClosestItem())
    elseif !has_key(g:outline_include_before_exclude, &filetype)
        # If filetype is not supported, then clean up the Outline
        # and put a motivational quote in Outline variable.
        var idx = rand(srand()) % len(quotes.quotes)
        Outline = quotes.quotes[idx]
        return ""
    endif
    return ""
enddef


export def RefreshWindow()
    UpdateOutline()
    # To refresh a window such a window must be obviously open
    if IsOpen()
        # If what is shown in the outline window is the Outline buffer, then
        # overwrite it. If it is shown a user-buffer DON'T overwrite it!
        if winbufnr(outline_win_id) == bufnr(g:outline_buf_name)
            # -----------------------------------------
            # clean outline and unlock outline buffer
            # -----------------------------------------
            win_execute(outline_win_id, 'setlocal modifiable noreadonly')
            deletebufline(winbufnr(outline_win_id), len(title) + 1, line('$',
                        \ outline_win_id))

            # ----------------------------------------------
            # Actually populate the window
            # ----------------------------------------------
            setbufline(winbufnr(outline_win_id), len(title) + 1, Outline)
            # Set outline syntax the same as the caller buffer syntax.
            win_execute(outline_win_id, 'setlocal syntax=' .. &syntax)
            win_execute(outline_win_id, 'setlocal nomodifiable readonly')

            # Locate
            if g:outline_enable_highlight
                Locate(FindClosestItem())
            endif
        # TODO: you may have a nasty recursion here that slow down everything.
        # You may consider throwing an error message instead.
        elseif  winbufnr(outline_win_id) != bufnr(g:outline_buf_name)
            # Close()
            # Open()
            # RefreshWindow()
            echoerr "Previous outline content has gone!"
                        \ .. " Close and re-open the outline window to "
                        \ .. "re-create a new one."
        endif
    endif
enddef


augroup Outline_autochange
    autocmd!
    autocmd WinLeave * if bufwinid(bufnr()) == outline_win_id
                \ && g:outline_autoclose | q | endif
augroup END
