vim9script

# setlocal colorcolumn=36

def BreakLines(string: string): list<string>
    var split_string = []
    var current_line = ""
    for word in split(string)
      var word_length = len(word)
      var tmp = 0
      # TODO how to convert bool to number in a more efficient way?
      if current_line != ''
          tmp = 1
      else
          tmp = 0
      endif
      if len(current_line .. ' ' .. word) + tmp <= g:outline_win_size
        current_line = current_line .. ' ' .. word
      elseif word_length <= g:outline_win_size
        add(split_string, current_line)
        current_line = word
      else
        var chars_left = g:outline_win_size - len(current_line)
        var partial_word = matchstr(word, '\k\{0,' .. chars_left .. '}\ze\S')
        add(split_string, current_line .. ' ' .. partial_word)
        current_line = word[matchend(word, '\k\{0,' .. chars_left .. '\}') : ]
        add(split_string, current_line)
        current_line = ""
      endif
    endfor
    if current_line != ""
        add(split_string, current_line)
    endif
    return split_string
enddef

export var quotes = []

var quote = "Return the non-negative square root of Float {expr} as a |Float|.
            \ {expr} must evaluate to a |Float| or a |Number|.
            \ When {expr} is negative the result is NaN (Not a Number).
            \ Returns 0.0 if {expr} is not a |Float| or a |Number|."
add(quotes, BreakLines(quote))

quote = "That's one small step for a man, a giant leap for mankind."
add(quotes, BreakLines(quote))

quote = "The love of money is the root of all evil."
add(quotes, BreakLines(quote))
