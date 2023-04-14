if !has('vim9script') ||  v:version < 900
  " Needs Vim version 9.0 and above
  echo "You need at least Vim 9.0"
  finish
endif

vim9script

# replica.vim
# github.com/ubaldot/vim-replica

# if exists('g:outline_loaded')
#     finish
# endif

g:outline_loaded = 0

g:outline_buf_name = "Outline"
g:outline_win_size = 29
g:show_private = 0

if !exists('g:outline_autostart')
     g:outline_autostart = 1
endif

if !exists('g:outline_alt_highlight')
     g:outline_alt_highlight = 0
endif

if !exists('g:outline_direction')
     g:outline_direction = "L"
endif

if !exists('g:outline_size')
     g:outline_size = 0 # Use 0 to take the half of the whole space
endif


# Commands definition: if a key (&filetype) don't exist in the defined dicts, use a default (= "default").
# command! ReplConsoleOpen silent :call replica#ReplOpen()
# command! -nargs=? ReplConsoleClose silent :call replica#ReplClose(<f-args>)
# command! ReplConsoleToggle silent :call replica#ReplToggle()
# command! ReplConsoleRestart silent :call replica#ReplShutoff() | replica#ReplOpen()
# command! -nargs=? ReplConsoleShutoff silent :call replica#ReplShutoff(<f-args>)

# command! -range ReplSendLines silent :call replica#SendLines(<line1>, <line2>)
# command! ReplSendCell silent :call replica#SendCell()
# command! -nargs=? -complete=file ReplSendFile silent :call replica#SendFile(<f-args>)

# command! ReplRemoveCells silent :call replica#RemoveCells()



# if !hasmapto('<Plug>ReplSendCell') || empty(mapcheck("<c-enter>", "ni"))
#     nnoremap <silent> <c-enter> <Cmd>ReplSendCell<cr>
#     inoremap <silent> <c-enter> <Cmd>ReplSendCell<cr>
# endif
