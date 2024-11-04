vim9script

#=====
# this function  parse caller through 
# reg exp and populate outline window
# ====

import autoload "../regex.vim"

export def CurrentItem(curr_item: string): string
    #return trim(matchstr(curr_item, '(.*'))
    return curr_item
enddef

export def FilterOutline(outline: list<string>): list<string>
    outline ->filter("v:val =~ " .. string(join(regex.outline_pattern_to_include["java"], '\|')))
            ->filter("v:val =~ " .. string(join(regex.outline_pattern_to_exclude["java"], '\|')))
    return outline
enddef

export def InverseSubstitution(outline_item: string): string
    return outline_item
enddef
