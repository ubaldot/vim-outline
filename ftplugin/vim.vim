vim9script


b:outline_include_before_exclude = g:outline_include_before_exclude[&filetype]
b:outline_pattern_to_include = g:outline_pattern_to_include[&filetype]
b:outline_pattern_to_exclude = g:outline_pattern_to_exclude[&filetype]

import "../lib/ftfunctions/vim.vim"
b:PreProcessOutline = vim.PreProcessOutline
