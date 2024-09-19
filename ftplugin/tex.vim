vim9script

import autoload "../lib/ftfunctions/tex.vim"

b:FilterOutline = tex.FilterOutline
b:CurrentItem = tex.CurrentItem
b:InverseSubstitution = tex.InverseSubstitution
