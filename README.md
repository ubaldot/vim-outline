# vim-outline
A simple outline sketcher for Vim.

## Introduction
Vim-outline parse your current buffer through a set of user-defined regex and 
it slam an outline in a side window. 

That's all!

Vim-outline further provides you with the following features:

1. tell you where you are in the main buffer with respect to the outline
through highlighting,
2. allow you to jumps from every outline line to the corresponding
line in the calling buffer,
3. a random motivational quote picked from our quotes database will
appear in the side window in place of an outline if a 'filetype' is not
supported.

At the time I was working with Python and Vim9script, hence only Python and
Vim9Script are supported by default, but you can easily add other languages.
See `:h OutlineAddNewLanguages`.

I wrote vim-outline mainly for myself because I had some issue when using Vista!
with ALE and Tagbar is based on tags, which is a feature that I don't really use.
What I needed was something easily configurable, fast and reliable that just
support me to get my job done, no matter if lacks bells and whistles
and if the outcome is just an imprecise sketch of my buffer with noisy entries.

## Installation
Use any plugin manager or the builtin Vim plugin manager. 

## Requirements
Outline is written in Vim9script, therefore you need at least Vim 9.0.
That is pretty much all. No ctags, nor LSP servers required.

## Usage
#### Commands
`:OutlineToggle` to open/close a side-window that shows an outline of
your current buffer.

`:OutlineJump` to jump on the outline window, select a line and
hit `<enter>` to jump back to the corresponding line in the calling buffer.
This command is very useful when you have many windows open in the same tab
and you want to jump directly to the outline window with one key-press.

`:OutlineRefresh` to update both the outline and the highlighting.
> Note: The refresh is asynchronous, meaning that the outline is updated only in
> response to the following events:
>
> 1. Newly opened outline,
> 2. Another buffer is entered,
> 3. Manual refresh.
> 
> In all the other cases, you have to refresh it manually through `:OutlineRefresh`.
> See `:h OutlineUsage` for more info.

#### Mappings
    # Default mappings
    nnoremap <silent> <F8> <Plug>OutlineToggle
    nnoremap <silent> <F7> <Plug>OutlineRefresh
    nnoremap <silent> <F6> <Plug>OutlineGoToOutline

## Configuration
For each filetype you can define some regex to be used to parse the current buffer and then to create an outline.

You can specify the regex through the following dictionaries:
```
# Default values
g:outline_pattern_to_include = {
            \ "python": ['^class', '^\s*def'],
            \ "vim": ['^\s*export', '^\s*def', '^\S*map',
                \ '^\s*\(autocmd\|autocommand\)', '^\s*\(command\|cmd\)',
                \ '^\s*sign' ]
            \ }
            
g:outline_pattern_to_exclude = {
            \ "python": ['^\s*def\s_\{-1,2}'],
            \ "vim": ['^\s*#']
            \ }
            
g:outline_include_before_exclude = {
            \ "python": false,
            \ "vim": false
            \ }
```
> Note: default values are overwritten by user values!

You also have some few other tweaking variables:
```
# Defaul values
g:outline_buf_name = "Outline!"
g:outline_win_size = 30
g:outline_enable_highlight = true
```
To see the current setting of a variable run `:echo g:<variable_name>`, for example `:echo g:outline_pattern_to_exclude`. 

See `:h OutlineConfiguration` for more info. 

## Help
`:h outline.txt` 

## Contributing
Contributions are more than welcome! See `:h OutlineContributing` for more info. 

