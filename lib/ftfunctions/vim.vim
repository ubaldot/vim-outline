vim9script

# =================================================
# The function parse the caller buffer through
# regular expressions and populate the Outline window.
# =================================================

export def CurrentItem(curr_item: string): string
    return trim(substitute(curr_item, "(.*", "", ''))
enddef

# TODO Parametrize the regex input
export def PopulateOutlineWindow(outline_win_id: number,
            \ include_before_exclude: dict<bool>,
            \ pattern_to_include: dict<list<string>>,
            \ pattern_to_exclude: dict<list<string>>): list<string>

    # ==============================================
    # SET OUTLINE WINDOW FILETYPE
    # ==============================================
    win_execute(outline_win_id, 'setlocal syntax=vim')

    # ==============================================
    # PARSE CALLING BUFFER
    # ==============================================
    # -----------------------------------
    #  Copy the whole buffer
    # -----------------------------------
    # TIP: For debugging use portions of source code and see what
    # happens, e.g. var Outline = getline(23, 98)
    var Outline = getline(1, "$")
    insert(Outline, "# ", 0) # We add a "#" because parsing the first line is always problematic

    # -----------------------------------
    # Filter user request
    # -----------------------------------
    # TODO: fix this
    if include_before_exclude["vim"]
        Outline = Outline ->filter("v:val =~ " .. string(join(pattern_to_include["vim"], ' \| ')))
                        \ ->filter("v:val !~ " .. string(join(pattern_to_exclude["vim"], ' \| ')))
    else
        Outline = Outline ->filter("v:val !~ " .. string(join(pattern_to_exclude["vim"], ' \| ')))
                    \ ->filter("v:val =~ " .. string(join(pattern_to_include["vim"], ' \| ')))
    endif

    # ==============================================
    # POPULATE WINDOW
    # ==============================================
    setbufline(winbufnr(outline_win_id), 1, Outline)

    return Outline
enddef
