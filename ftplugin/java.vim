vim9script

def OutlinePreProcessInternal(outline: list<string>): list<string>
    #javadoc string removal TODO
    var i = 0
    var is_javadoc = false

    var tmp_string = "<hshnnTejwqik93la,AMK3N2MNMAKPD+03mn2nhkalpdpk3nsla>"
    for item in outline
        i = i + 1
    endfor
    return outline
enddef

import autoload "../lib/ftfunctions/java.vim"

b:OutlinePreProcessInternal = OutlinePreProcessInternal
b:FilterOutline = java.FilterOutline
b:CurrentItem = java.CurrentItem
b:InverseSubstituion = java.InverseSubstitution
