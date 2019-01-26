class Judge
  def self.check_answer(guess, answer)
    coder = HTMLEntities.new
    guess = coder.decode(guess)
    answer = coder.decode(answer)

    guess.gsub!('&', 'and')
    guess.gsub!(/[^0-9a-z ]/, '')
    guess.gsub!(/^(who |what |where |when |whats )(is |are |was |were )?(a |an |the |to )?|^(a |an |the |to )/, '')

    answer.gsub!('&', 'and')
    answer.gsub!(/[^0-9a-z ]/, '')
    answer.gsub!(/^(a |an |the |to )/, '')

    levenshtein_distance =  Levenshtein.distance(guess, answer)
    levenshtein_distance <= 2 ? true : false
  end

  def self.parse_text(text)
    text.gsub!(/#[A-Z0-9]{6}/, '')
    tweeted_words = text.split(" ")
    non_special_tweeted_words = tweeted_words.select { |word| word[0] != '@' && word[0] != '#' }

    non_special_tweeted_words.join(" ")
  end
end
