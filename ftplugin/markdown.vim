vim9script

import autoload "../lib/ftfunctions/markdown.vim"

b:FilterOutline = markdown.FilterOutline
b:CurrentItem = markdown.CurrentItem
b:InverseSubstitution = markdown.InverseSubstitution
