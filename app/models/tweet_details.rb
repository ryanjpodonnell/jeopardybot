class TweetDetails
  attr_reader :code, :guess, :answer, :response, :value, :player_handle

  def initialize(tweet)
    hashtags = tweet.hashtags
    code = hashtags.first.text.upcase
    clue = Clue.find_by(:code => code)

    @code = code
    @player_handle = tweet.uri.to_s.split('/')[3]
    @guess = Judge.parse_text(tweet.text.dup)
    @answer = clue.answer
    @response = Judge.check_answer(@guess.downcase, @answer)
    @value = calculate_value(clue)
  end

  private

  def calculate_value(clue)
    if @response == true
      return clue.value
    else
      return -clue.value
    end
  end
end
