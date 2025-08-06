vim9script

# Imports
import autoload "./quotes.vim"
import autoload "./regex.vim"

# Script variables
const supported_filetypes = keys(regex.patterns)

var title: list<string> = []
var Outline: list<string> = [""] # It does not like [] initialization
var Outline_mapping: list<number> = []
var outline_win_id: number = 0
var user_regex: string = ""

sign define CurrentItem linehl=CursorLine

def Echoerr(msg: string)
  echohl ErrorMsg | echom $'[vim-outline] {msg}' | echohl None
enddef

# TODO: add when the filetype is preserved through different windows
def IsSupportedFiletype(): bool
  return index(supported_filetypes, &filetype) != -1
enddef

# Script functions
def HighlightOutlineLine(line_nr: number)
  # Highlight target_item in the outline window
  # line_nr is respect to the Outline! window.
  win_execute(outline_win_id, 'setlocal modifiable noreadonly')

  setwinvar(win_id2win(outline_win_id), "line_nr", line_nr)

  win_execute(outline_win_id,
    "sign_unplace('', {buffer: g:outline_buf_name}) ")
  win_execute(outline_win_id, 'cursor(w:line_nr, 1) | norm! ^')

  win_execute(outline_win_id,
    'sign_place(w:line_nr, "",  "CurrentItem", '
       .. ' g:outline_buf_name, {"lnum": w:line_nr})')

  win_execute(outline_win_id, 'setlocal nomodifiable readonly')
enddef

def FindClosestItemLine(): number
  # Search the item at minimum distance with the cursor (from above)
  # Note that the maximum distance is curr_line - 0 = curr_line
  # Here we are in the caller-buffer coordinates
  var curr_line_nr = line('.')
  var curr_line = getline('.')
  var dist_min = curr_line_nr
  var dist = curr_line_nr
  var found_line = 0

  # OBS! You only find the item at minimum distance,
  # but you don't know if there is any duplicate of such an item.
  for item in Outline
    dist = curr_line_nr - search($'\V{item}', 'cnbW')
    # OBS! dist is always >= 0
    if dist <= dist_min
      dist_min = dist
      found_line = curr_line_nr - dist
    endif
  endfor

  # If the search towards the top hit 0, return 0.
  # Otherwise, return found_item.
  if dist_min != curr_line_nr
    return found_line
  else
    return 0
  endif
enddef

def GoToDefinition()
  # You are in the Outline window
  var curr_line_nr = max([1, line('.') - len(title)])

  # OBS! If the first line of the outline is not the buffer name, then things
  # won't work any longer
  var coupled_buffer = getline(1)
  wincmd p
  exe $'buffer {coupled_buffer}'

  # Jump to the correct line in the calling buffer
  cursor(Outline_mapping[curr_line_nr - 1], 1)

  # Highlight where did you jump on the Outline window
  if !g:outline_autoclose
    HighlightOutlineLine(curr_line_nr + len(title))
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
    win_execute(outline_win_id, 'bwipe!')
    # In case there are erroneously other Outline windows open
    for wind in win_findbuf(bufnr($'^{g:outline_buf_name}$'))
      win_execute(wind, 'bwipe!')
    endfor

    # Reset the user_regex
    user_regex = ""
  endif
enddef

def SetTitle()
  const heading = $'{expand('%')}'
  const separator = repeat('-', strlen(heading))
  title = [heading, separator, '']

  setbufline(winbufnr(outline_win_id), 1, title)
  win_execute(outline_win_id, $'matchadd("WarningMsg", "{heading}")')
  win_execute(outline_win_id, $'matchadd("WarningMsg", "{separator}")')
enddef

def Open(regex_from_user: string =""): number
  # TODO: add when the filetype is preserved through different windows
  # if !IsSupportedFiletype()
  #   Echoerr("unsupported filetype")
  #   return -1
  # endif
  # Create empty win from current buffer and give it a name
  win_execute(win_getid(), $'vertical split {g:outline_buf_name}')
  outline_win_id = win_findbuf(bufnr('$'))[0]

  # Set some stuff in the newly created window
  win_execute(outline_win_id, 'wincmd L')
  win_execute(outline_win_id, $'vertical resize {g:outline_win_size}')
  win_execute(outline_win_id,
        'setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap'
       .. ' nonumber winfixwidth')

  # Set few w: local variables
  # Let the Outline window to access this script by passing a function
  setwinvar(win_id2win(outline_win_id), "GoToDefinition", GoToDefinition)
  win_execute(outline_win_id, 'nnoremap <buffer> <silent> <enter> <ScriptCmd>'
        .. ' w:GoToDefinition()<cr>')
  if has("gui")
    win_execute(outline_win_id, 'nnoremap <buffer> <silent> <2-LeftMouse>'
          .. ' <ScriptCmd>w:GoToDefinition()<cr>')
  endif

  # Set title
  SetTitle()

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

  # Set script-variable
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
    if Open(regex_from_user) != -1
      RefreshWindow()
      GoToOutline()
    endif
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
         && bufnr() != winbufnr(outline_win_id)
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
    return trim(substitute(getline(FindClosestItemLine()), "(.*", "", ''))
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
    if winbufnr(outline_win_id) == bufnr(g:outline_buf_name)
      # -----------------------------------------
      # clean outline and unlock outline buffer
      # -----------------------------------------
      win_execute(outline_win_id, 'setlocal modifiable noreadonly')
      deletebufline(winbufnr(outline_win_id), len(title) + 1,
            line('$', outline_win_id))

      # ----------------------------------------------
      # Actually populate the window
      # ----------------------------------------------
      setbufline(winbufnr(outline_win_id), len(title) + 1, Outline)
      # Set outline syntax the same as the caller buffer syntax.
      # DON'T SET filetype otherwise it is going to trigger lot of FileType
      # events!
      win_execute(outline_win_id, 'setlocal syntax=' .. &syntax)

      # Show where you are in the Outline window
      if g:outline_enable_highlight
        const line_nr = FindClosestItemLine()
        HighlightOutlineLine(index(Outline_mapping, line_nr) + len(title) + 1)
      endif
    # You may consider throwing an error message instead.
    elseif  winbufnr(outline_win_id) != bufnr(g:outline_buf_name)
       Echoerr("Previous outline content has gone!"
             .. " Close and re-open the outline window to "
             .. "re-create a new one.")
    endif
  endif
enddef

def FilterOutline(lines: list<string>)
  # 'decorated_lines' is of the form [[1, 'foo'], [2, 'bar'], ...]
  # Those are needed to keep track of the line numbers of the calling buffer,
  # otherwise it becomes messy to jump back and forth to the current location
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

augroup Outline_autochange
  autocmd!
  autocmd WinLeave * if bufwinid(bufnr()) == outline_win_id
        \ && g:outline_autoclose | q | endif
augroup END
