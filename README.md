# vim-outline

A simple outline sketcher for Vim.

<p align="center">
<img src="/OutlineDemo.gif" width="60%" height="60%">
</p>

## Introduction

Vim-outline parse your current buffer and slam an outline in a side-window.
That's all!

The outline is far from being perfect, but it gives you a good idea of how
your code is structured and it allows you to jump from one place to another.
It is perhaps the plugin that I use more!

At the moment the supported language are `python`, `vim9script`, `tex` and
`markdown`. For non supported languages, you will be entertained with some
famous quotes every time you attempt to trigger the outline window.

Nevertheless, if you really don't like the quotes, and you are good with regex
and you want to add support for another language you are welcome to send PR:s!
Take a look at`:h OutlineAddNewLanguages` for more details.

## Installation

Use any plugin manager or the builtin Vim plugin manager.

## Requirements

Vim-outline is written in _Vim9script_, therefore you need at least _Vim 9.0_.
That is pretty much all. No ctags, nor LSP servers required.

## Usage

#### Commands

`:OutlineToggle` open/close a side-window that shows an outline of your
current buffer.

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

You only have few tweaking variables:

```# Default values
g:outline_buf_name = "Outline!"
g:outline_win_size = &columns / 4
g:outline_enable_highlight = true
```

See `:h OutlineConfiguration` for more info.

## Create arbitrary outlines

What about slamming `:global` results in the Outline window such that when you
hit enter on an Outline line you jump to the corresponding line in the buffer?

You can do that with a little hack, as explained next. We assume that you want
to do this game for `cpp` filetypes.

#### Step 1

Create a `cpp.vim` file in `./ftplugin` with the following content

```
vim9script

def FilterOutline(outline: list<string>): list<string>
    return outline ->filter("v:val =~ "
    \ .. string(join(g:outline_pattern_to_include["cpp"], '|')))
enddef

b:FilterOutline = FilterOutline
```

#### Step 2

Add the following lines to your `.vimrc`

```
    extend(g:outline_include_before_exclude, {cpp: true})
    extend(g:outline_pattern_to_include, {cpp: ['<KEEP-ME!>']})
```

#### Step 3

Comment each line that you want to keep in the outline with `// <KEEP-ME!>`.

At this point, call `:OutlineToggle` (or hit <F8> if you are using the default
mapping) and see what happens. Jumps and localization functions should work
automatically.

## Help

`:h outline.txt`

## Contributing

Contributions are more than welcome! See `:h OutlineContributing` for more
info.

## License

BSD3-Clause.
