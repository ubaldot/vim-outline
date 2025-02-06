# vim-outline

A simple outline sketcher for Vim.

<p align="center">
<img src="/OutlineDemo.gif" width="60%" height="60%">
</p>

## Introduction

Vim-outline parse your current buffer and slam an outline in a side-window
based on a set of regex. That's all!

If you pass a regex to `:Outline` command, then the tool will have the same
behavior as `:global`, but here you can jump back and forth between the
outline and the original windows. If no regex are passed, then the outline
windows is filled depending on the `filetype` (if such a `filetype` is
supported).

The `filetype` outline is far from being perfect, but it gives you a good idea
of how your buffer is structured. It is perhaps the plugin that I use more!

## Installation

Use any plugin manager or the builtin Vim plugin manager.

## Requirements

Vim-outline is written in _Vim9script_, therefore you need at least _Vim 9.0_.
That is pretty much all. No ctags, nor LSP servers required.

## Usage

#### Commands

`:OutlineToggle [{regex}]` open/close a side-window that shows an outline of
your current buffer based on `{regex}`. If `{regex}` is not passed, then the
outline window will depends on the current buffer `filetype`.

`:OutlineJump` jump on the outline window. Such a command is handy when you
have different windows open in the same tab and you want to jump directly to
the outline window with one key-press.

`:OutlineRefresh` update outline & locate yourself.

#### Mappings

```
# Default mappings
nmap <silent> <F8> <Plug>OutlineToggle
nmap <silent> <leader>l <Plug>OutlineRefresh
nmap <silent> <leader>o <Plug>OutlineGoToOutline
```

Feel free to change them at your convenience.

## Configuration

The basic configuration variables are the following:

```# Default values
g:outline_buf_name = "Outline!"
g:outline_win_size = &columns / 4
g:outline_enable_highlight = true
```

See `:h OutlineConfiguration` for additional configuration variables.

## Create arbitrary outlines

You can create arbitrary outlines for different `filetypes` in a very easy
way. You just have to write your own regex. For example, assume that you want
to create a custom outline for `cpp` filetypes:

#### Step 1

Add the following lines to your `.vimrc`

```
    extend(g:outline_include_before_exclude, {cpp: true})
    extend(g:outline_pattern_to_include, {cpp: ['<KEEP-ME!>']})
```

#### Step 3

Comment each line that you want to keep in the outline with `// <KEEP-ME!>`.

At this point, call `:OutlineToggle` and see what happens. Jumps and
localization functions should work automatically.

## Help

`:h outline.txt`

## Contributing

Contributions are more than welcome! See `:h OutlineContributing` for more
info.

## License

BSD3-Clause.
