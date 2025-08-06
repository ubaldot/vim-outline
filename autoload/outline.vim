vim9script

# ========================================
# Everything happens in the current buffer
# with the exception of GoToDefinition()
# ========================================

# Imports
import autoload "./quotes.vim"
import autoload "./regex.vim"

# Script variables
var supported_filetypes = keys(regex.patterns)

var title: list<string> = ['Go on a line and hit <enter>', 'to jump to definition.', ""]
var Outline: list<string> = [""] # It does not like [] initialization
var Outline_mapping: list<number> = []
var outline_win_id: number = 0
var user_regex: string = ""

sign define CurrentItem linehl=CursorLine

export def Echoerr(msg: string)
  echohl ErrorMsg | echom $'[helpme] {msg}' | echohl None
enddef

# TODO: remove me
def CountIndexInstances(target_item: string): list<any>
        # Return the line numbers where target_item appears in the Outline
        # window
        var curr_line_nr = line('.')
        var num_duplicates = len(getline(1, curr_line_nr)
                     -> filter($"v:val ==# '{target_item}'"))

        # List of lines where there are duplicates in the Outline window
        var lines = []
        for ii in range(0, len(Outline) - 1)
            if Outline[ii] ==# target_item
                add(lines, ii)
            endif
        endfor
        return [num_duplicates, lines]
enddef

# Script functions
# TODO Modify: you have the exact line number
def Locate(line_nr: number)
    # Highlight target_item (aka closest item) in the outline window
    win_execute(outline_win_id, 'setlocal modifiable noreadonly')
    win_execute(outline_win_id, "sign_unplace('', {buffer:
                \ g:outline_buf_name}) ")

    win_execute(outline_win_id, 'sign_place(line_nr, "",
                \ ''CurrentItem'', g:outline_buf_name, {''lnum'':
                \ line_nr})')
    # If you have a valid target_item, then check if there are duplicates,
    # and highlight the correct one.
    # if target_item !=# ""
    #     var tmp = CountIndexInstances(target_item)
    #     var num_duplicates = tmp[0]
    #     var lines = tmp[1]
    #     # Now you know what you should highlight
    #     var line_nr = lines[num_duplicates - 1] + len(title) + 1
    #     setwinvar(win_id2win(outline_win_id), "line_nr", line_nr)
    #     win_execute(outline_win_id, 'cursor(w:line_nr, 1) | norm! ^')
    #     win_execute(outline_win_id, 'sign_place(w:line_nr, "",
    #                 \ ''CurrentItem'', g:outline_buf_name, {''lnum'':
    #                 \ w:line_nr})')
    # endif
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
  messages clear
    var curr_line_nr = max([1, line('.') - len(title)])
    echom curr_line_nr

    var coupled_buffer = getline(1)
    # echom coupled_buffer
    wincmd p
    if bufname() !=# coupled_buffer
      exe $'buffer {coupled_buffer}'
    endif

    cursor(Outline_mapping[curr_line_nr - 1], 1)

    # TODO
    # var target_item = getline('.')
    if !g:outline_autoclose
        Locate(curr_line_nr + len(title))
    endif
enddef

# TODO update
def GoToDefinition_OLD()
    # In two steps:
    # 1. Search selected item in the Outline (including duplicates),
    var curr_line_nr = max([1, line('.') - len(title)])
    var target_item = getline('.')
    # counter keeps track of the number of duplicated until this line.
    var counter = len(Outline[0 : curr_line_nr - 1]
                 -> filter($"v:val ==# '{target_item}'"))

    # Go to the actual buffer
    # TODO: this can be improved. What if the buffer and the Outline don't
    # match?
    var coupled_buffer = getline(1)
    # echom coupled_buffer
    wincmd p
    if bufname() !=# coupled_buffer
      exe $'buffer {coupled_buffer}'
    endif

    # 2a. If you used any substitutions, then you have to revert them.
    # OBS! It works only if the substitution is 1-1, i.e. 'exactly A' is
    # substituted with 'B.
    var item_on_buffer = target_item
    # if index(supported_filetypes, &filetype) != -1 && empty(user_regex)
    #   item_on_buffer = InverseSubstitution(target_item)
    # endif


    # 2. Jump back to the main buffer and search for the selected item.
    # The number of jumps needed to reach the target item are counted from the
    # beginning of the file
    cursor(1, 1)
    for ii in range(counter)
        # TODO This looks for a regular expression not for the literal string!
        search($'\V{item_on_buffer}', "W")
    endfor

    if !g:outline_autoclose
        Locate(target_item)
    endif
enddef

export def GoToOutline()
    if IsOpen()
      RefreshWindow()
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

        # Reset the user_regex
        user_regex = ""
    endif
enddef


def Open(regex_from_user: string =""): number
  # Create empty win from current buffer and give it a name
  win_execute(win_getid(), $'vertical split {g:outline_buf_name}')
  outline_win_id = win_findbuf(bufnr('$'))[0]

  # Set some stuff in the newly created window
  win_execute(outline_win_id, 'wincmd L')
  win_execute(outline_win_id, $'vertical resize {g:outline_win_size}')
  win_execute(outline_win_id,
        \    'setlocal buftype=nofile bufhidden=wipe
        \ nobuflisted noswapfile nowrap
        \ nonumber norelativenumber noscrollbind winfixwidth')


  # Set few w: local variables
  # Let the Outline window to access this script by passing a function
  setwinvar(win_id2win(outline_win_id), "GoToDefinition", GoToDefinition)
  win_execute(outline_win_id, 'nnoremap <buffer> <silent> <enter> <ScriptCmd>
        \ w:GoToDefinition()<cr>')
  if has("gui")
    win_execute(outline_win_id, 'nnoremap <buffer> <silent> <2-LeftMouse>
          \ <ScriptCmd>w:GoToDefinition()<cr>')
  endif

  # Set title
  var heading = $'{expand('%')}'
  var separator = repeat('-', strlen(heading))
  title = [heading, separator, '']
  setbufline(winbufnr(outline_win_id), 1, title)
  win_execute(outline_win_id, $'matchadd("WarningMsg", "{heading}")')
  win_execute(outline_win_id, $'matchadd("WarningMsg", "{separator}")')
  # win_execute(outline_win_id, 'matchaddpos(''Question'',
  #             \ range(1, len(title)))')
  # Add some sugar
  win_execute(outline_win_id, 'nnoremap <buffer> j j^')
  win_execute(outline_win_id, 'nnoremap <buffer> k k^')
  win_execute(outline_win_id, 'nnoremap <buffer> <down> <down>^')
  win_execute(outline_win_id, 'nnoremap <buffer> <up> <up>^')
  win_execute(outline_win_id, 'cursor(len(title) + 1, 1)')

  # winfixbuf
  if exists('+winfixbuf')
    win_execute(outline_win_id, 'setlocal winfixbuf' )
  endif

  # Set script global-variable
  user_regex = regex_from_user
  return outline_win_id
enddef


def IsOpen(): bool
  return win_id2win(outline_win_id) > 0 ? true : false
enddef

export def Toggle(regex_from_user: string = "")
  if IsOpen()
    Close()
  else
    Open(regex_from_user)
    RefreshWindow()
    GoToOutline()
  endif
enddef

def UpdateOutlineFromUser()
  Outline = getline(1, "$")
  insert(Outline, &commentstring, 0)
  # Filter is in-place function
  Outline ->filter($"v:val =~ '{user_regex}'")
enddef

def UpdateOutline(): string
  # This function only update the Outline script variable, even if the
  # outline window is closed.
  # If the current buffer is the outline itself then it does not make sense
  # to update the outline.

  if index(supported_filetypes, &filetype) != -1
        \ && bufnr() != winbufnr(outline_win_id)
    # -----------------------------------
    #  Copy the whole buffer
    # -----------------------------------
    # TIP: For debugging use portions of source code and see what
    # happens, e.g. var Outline = getline(23, 98)
    var buffer_lines = getline(1, "$")
    # We add a comment line because parsing the first line is always
    # problematic
    insert(buffer_lines, &commentstring, 0)

    # -----------------------------------
    # Filter user request
    # -----------------------------------
    if index(supported_filetypes, &filetype) != -1
      FilterOutline(buffer_lines)
    endif

    # TODO: I can't remember, but this looks like an attempt to get the
    # current function name and to be placed in the statusline?
    # If this feature is unused, then perhaps this function shall not return
    # anything?
    return trim(substitute(FindClosestItem(), "(.*", "", ''))
  elseif index(supported_filetypes, &filetype) == -1
    # If filetype is not supported, then clean up the Outline
    # and put a motivational quote in Outline variable.
    SetFamousQuote()
    return ""
  endif
  return ""
enddef

def SetFamousQuote()
  var idx = rand(srand()) % len(quotes.quotes)
  Outline = quotes.quotes[idx]
enddef

export def RefreshWindow()
    if empty(user_regex)
      UpdateOutline()
    else
      UpdateOutlineFromUser()
    endif
    # To refresh a window such a window must be obviously open
    if IsOpen()
        # If what is shown in the outline window is the Outline buffer, then
        # overwrite it. If it is shown a user-buffer DON'T overwrite it!
        # TODO This is not a problem if 'winfixbuf' option is on
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

def FilterOutline(lines: list<string>)
  # 'decorated_lines' is of the form [[1, 'foo'], [2, 'bar'], ...]
  var decorated_lines = range(len(lines))->map((ii, _) => [ii, lines[ii]])

  if index(keys(regex.patterns), &filetype) != -1
    for lambda in regex.patterns[&filetype]
      decorated_lines = decorated_lines->filter((_, pair) => call(lambda, [pair[0], pair[1]]))
    endfor
  else
    Echoerr($"Filetype '{&filetype}' not supported")
  endif

  # Separate original buffer lines numbers with the actual lines
  # 'Outline' and 'Outline_mappings' are script-local variables.
  Outline = decorated_lines->mapnew((_, pair) => pair[1])
  Outline_mapping = decorated_lines->mapnew((_, pair) => pair[0])

  if index(keys(regex.sanitizers), &filetype) != -1
    for subs in regex.sanitizers[&filetype]
      Outline ->map((idx, val) => substitute(val, keys(subs)[0], values(subs)[0], ''))
    endfor
  endif
enddef

# TODO Remove me
def InverseSubstitution(outline_item: string): string
  # Given a string in the outline, it reconstruct the string in the original
  # file, so that the jump from the outline to the main buffer is accurate.
  var tmp = outline_item
  if has_key(regex.outline_inverse_substitutions, &filetype)
    for subs in regex.outline_inverse_substitutions[&filetype]
      tmp = tmp ->substitute(keys(subs)[0], values(subs)[0], '')
    endfor
  endif
  return tmp
enddef

augroup Outline_autochange
    autocmd!
    autocmd WinLeave * if bufwinid(bufnr()) == outline_win_id
                \ && g:outline_autoclose | q | endif
augroup END
