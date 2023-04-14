vim9script

# TODO: create a function in ftplugin: # https://vi.stackexchange.com/questions/11231/is-it-possible-to-create-a-function-with-the-same-name-for-different-filetypes

import "../lib/ftfunctions/python.vim"
b:PyOutlineParseBuffer = function('python.PyOutlineParseBuffer')
