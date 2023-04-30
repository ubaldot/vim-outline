# vim-outline
A simple outline sketcher for Vim.

<p align="center">
<img src="/OutlineDemo.gif" width="60%" height="60%">
</p>

## Introduction
Vim-outline parse your current buffer through a set of
user-defined regex or parsing functions and slam the result in a
side-window.

That's all!

Well, in reality is not, in-fact Vim-outline further provides you with the
following features:

1. Locate your current position on the outline,
2. Jump from outline entries to the corresponding buffer lines,
3. Feed you with random motivational quote if a *filetype* is not supported.
   [Cringe mode ON!]


At the time I was working with Python and Vim9script, hence Python and
Vim9Script are supported by default, but you can easily add other languages.
See `:h OutlineAddNewLanguages`.

I wrote vim-outline mainly for myself because I had some issue when using
Vista! with ALE and Tagbar require ctags, which is a tool that I don't
have installed (I know, I should).

What I needed was a self-contained tool (i.e. no-dependencies), which is
easily configurable, fast and reliable and that would support me to get
my job done, no matter if lacks bells and whistles and if the outcome
is an imprecise sketch with noisy entries.

If you work with Data Science you may also want to take a look at
[vim-replica](https://github.com/ubaldot/vim-replica).

## Installation
Use any plugin manager or the builtin Vim plugin manager.

## Requirements
Vim-outline is written in *Vim9script*, therefore you need at least *Vim 9.0*.
That is pretty much all. No ctags, nor LSP servers required.

## Usage
#### Commands
`:OutlineToggle` open/close a side-window that shows an outline of your
current buffer.

`:OutlineJump` jump on the outline window.  Such a command is handy
when you have different windows open in the same tab and you want to jump
directly
to the outline window with one key-press.

`:OutlineRefresh` update outline & locate yourself.


#### Mappings
```
# Default mappings
nmap <silent> <F8> <Plug>OutlineToggle
nmap <silent> <leader>l <Plug>OutlineRefresh
nmap <silent> <leader>o <Plug>OutlineGoToOutline
```


> **Note**
> The refresh is asynchronous, meaning that outline & localization are
> automatically updated only in response to the following events:
>
> 1. Newly opened outline,
> 2. Another buffer is entered,
>
> In all the other cases, you have to refresh it manually through
> `:OutlineRefresh`.  See `:h OutlineUsage` for more info.



## Configuration
For each filetype you can define some regex to be used to parse the
current buffer through the following dictionaries:
```
# Default values
g:outline_pattern_to_include = {"python": ['^class', '^\s*def'],
                                \  "vim": ['^\s*export', '^\s*def', '^\S*map',
                                \           '^\s*\(autocmd\|autocommand\)',
                                \           '^\s*\(command\|cmd\)', '^\s*sign'
                                ]}

g:outline_pattern_to_exclude = {"python": ['^\s*def\s_\{-1,2}'], "vim":
['^\s*#'] }

g:outline_include_before_exclude = {"python": false, "vim": false}
```



You also have other tweaking variables:
``` # Default values
g:outline_buf_name = "Outline!"
g:outline_win_size = 30
g:outline_enable_highlight = true
```
See `:h OutlineConfiguration` for more info.

> **Warning**
> The default values are overwritten by user values!
> To see the current setting of a variable run `:echo g:<variable_name>`, for
> example `:echo g:outline_pattern_to_exclude`.


## Can I use it for languages that are not supported yet?
Yes, it *should* work... with a little hack. <br>
I hope it won't bother you too
much!<br>

As an example, I'll show you how to hack it for `.cpp` files, but the
same principle should apply, *mutatis-mutandis*, to any other filetype.

#### Step 1
Create a `cpp.vim` file in `.vim/ftplugin` with the following content

```
vim9script

def FilterOutline(outline: list<string>): list<string>
    return outline ->filter("v:val =~ "
    \ .. string(join(g:outline_pattern_to_include["cpp"], '|')))
enddef

b:FilterOutline = FilterOutline
```

#### Step 2
Add the following to your `.vimrc`
```
extend(g:outline_pattern_to_include, {"cpp": ['<KEEP-ME!>']})
```

#### Step 3
Comment each line that you want to show in the outline with `// <KEEP-ME!>`

At this point, call `:OutlineToggle` (or hit `<F8>` if you are using the
default mapping) and see what happens.
Jumps and localization functions should work automatically.


## Help
`:h outline.txt`

## Contributing
Contributions are more than welcome!
See `:h OutlineContributing` for more info.
