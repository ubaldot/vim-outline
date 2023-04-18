vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

# TODO:remove
export def CurrentItem(curr_item: string): string
    return trim(substitute(curr_item, "(.*", "", ''))
enddef

export def PreProcessOutline(outline_win_id: number, Outline: list<string>): list<string>
    return Outline
enddef
