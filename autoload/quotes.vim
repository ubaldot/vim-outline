vim9script

# TODO Try to simplify this function
def BreakLines(string: string): list<string>
    var split_string = []
    var current_line = ""
    for word in split(string)
      var word_length = len(word)
      var tmp = 0
      # TODO how to convert bool to number in a more efficient way?
      # Using a ternary operator?
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

# -----------------------------
#  Start quotes
# -----------------------------
export var quotes = []

var quote = "'That's one small step for a man, a giant leap for mankind.'"
add(quotes, BreakLines(quote))

quote = "'The love of money is the root of all evil.'"
add(quotes, BreakLines(quote))

quote = "'The greatest glory in living lies not in never falling, but in rising every time we fall.'"
add(quotes, BreakLines(quote))

quote = "'The way to get started is to quit talking and begin doing.'"
add(quotes, BreakLines(quote))

quote = "'If life were predictable it would cease to be life, and be without flavor.'"
add(quotes, BreakLines(quote))

quote = "'If you look at what you have in life, you'll always have more. If you look at what you don't have in life, you'll never have enough.'"
add(quotes, BreakLines(quote))

quote = "'If you set your goals ridiculously high and it's a failure, you will fail above everyone else's success.'"
add(quotes, BreakLines(quote))

quote = "'Technology is best when it brings people together.'"
add(quotes, BreakLines(quote))

quote = "'It has become appallingly obvious that our technology has exceeded our humanity.'"
add(quotes, BreakLines(quote))

quote = "'It is only when they go wrong that machines remind you how powerful they are.'"
add(quotes, BreakLines(quote))

quote = "'The Web as I envisaged it, we have not seen it yet. The future is still so much bigger than the past.'"
add(quotes, BreakLines(quote))

quote = "'If it keeps up, man will atrophy all his limbs but the push-button finger.'"
add(quotes, BreakLines(quote))

quote = "'If future generations are to remember us more with gratitude than sorrow, we must achieve more than just the miracles of technology. We must also leave them a glimpse of the world as it was created, not just as it looked when we got through with it.'"
add(quotes, BreakLines(quote))

quote = "'Once a new technology rolls over you, if you're not part of the steamroller, you're part of the road.'"
add(quotes, BreakLines(quote))

quote = "'It's not a faith in technology. It's faith in people.'"
add(quotes, BreakLines(quote))

quote = "'Technology is a useful servant but a dangerous master.'"
add(quotes, BreakLines(quote))

quote = "'The advance of technology is based on making it fit in so that you don't really even notice it, so it's part of everyday life.'"
add(quotes, BreakLines(quote))

quote = "'It’s time to kick ass and chew bubble gum…and I’m all outta gum.'"
add(quotes, BreakLines(quote))

quote = "'What is a man? A Miserable little pile of secrets!'"
add(quotes, BreakLines(quote))

quote = "'We’re not tools of the government or anyone else. Fighting was the only thing I was good at, but at least I always fought for what I believed in.'"
add(quotes, BreakLines(quote))

quote = "'They were all dead. The final gunshot was an exclamation mark to everything that had led to this point. I released my finger from the trigger. And then it was over.'"
add(quotes, BreakLines(quote))

quote = "'You were almost a Jill sandwich!'"
add(quotes, BreakLines(quote))

quote = "'The sun went down with practiced bravado. Twilight crawled across the sky, laden with foreboding. I didn’t like the way the show started. But they had given me the best seat in the house. Front row center.'"
add(quotes, BreakLines(quote))

quote = "'It’s dangerous to go alone, take this!'"
add(quotes, BreakLines(quote))

quote = "'I raised you, and loved you, I’ve given you weapons, taught you techniques, endowed you with knowledge. There’s nothing more for me to give you. All that’s left for you to take in my life.'"
add(quotes, BreakLines(quote))

quote = "'Thank you, Mario! But our Princess is in another castle!'"
add(quotes, BreakLines(quote))

quote = "'Dreams have a nasty habit of going bad when you’re not looking.'"
add(quotes, BreakLines(quote))

quote = "'No matter how dark the night, the morning always comes.'"
add(quotes, BreakLines(quote))

quote = "'You’ve met with a terrible fate, haven’t you?'"
add(quotes, BreakLines(quote))

quote = "'May the Force be with you.'"
add(quotes, BreakLines(quote))

quote = "'It's alive! It's alive!'"
add(quotes, BreakLines(quote))

quote = "'My mama always said life was like a box of chocolates. You never know what you're gonna get.'"
add(quotes, BreakLines(quote))

quote = "'If you build it, he will come.'"
add(quotes, BreakLines(quote))

quote = "'Magic Mirror on the wall, who is the fairest one of all?'"
add(quotes, BreakLines(quote))

quote = "'I am your father.'"
add(quotes, BreakLines(quote))

quote = "'You talking to me?'"
add(quotes, BreakLines(quote))

quote = "'Roads? Where we're going we don't need roads.'"
add(quotes, BreakLines(quote))

quote = "'Toto, I've a feeling we're not in Kansas anymore.'"
add(quotes, BreakLines(quote))

quote = "'You fight like a dairy farmer.'"
add(quotes, BreakLines(quote))

quote = "'Look behind you, a Three-Headed Monkey!'"
add(quotes, BreakLines(quote))

quote = "'I’m selling these fine leather jackets.'"
add(quotes, BreakLines(quote))

quote = "'I must have left it in my other pants.'"
add(quotes, BreakLines(quote))

quote = "'So you want to be a pirate, eh? You look more like a flooring inspector.'"
add(quotes, BreakLines(quote))

quote = "'LeChuck? He's the guy that went to the Governor's for dinner and never wanted to leave. He fell for her in a big way, but she told him to drop dead. So he did. Then things really got ugly.'"
add(quotes, BreakLines(quote))

quote = "'Hey, Amigo! You Know You Have a Face Beautiful Enough To Be Worth Two Thousand Dollars?'"
add(quotes, BreakLines(quote))

quote = "'God's Not On Our Side Because He Hates Idiots, Also.'"
add(quotes, BreakLines(quote))

quote = "'The Next Town Is 70 Miles... If You Save Your Breath, I Feel a Man Like You Could Manage It.'"
add(quotes, BreakLines(quote))

quote = "'You May Run The Risks, My Friend, But I Do The Cutting. If We Cut Down My Percentage... Who knows? It Might Just Interfere With My Aim.'"
add(quotes, BreakLines(quote))
