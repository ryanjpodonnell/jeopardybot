class Player
  attr_accessor :handle, :score
  
  def initialize(handle, score)
    @handle = handle
    @score = score
  end
end

def twitter
  twitter = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end
end

def check_answer(tweet, clue)
  tweet.gsub!(/[^0-9a-z ]/i, '')
  clue = clue.split(' ').select{|word| word[0] != '('}
  clue.shift if clue.first == "the"
  clue.map!{|word| word.gsub!(/[^0-9a-z ]/i, '')}
  clue_dup = clue.dup
  clue_dup.each do |word|
    clue.delete(word) if tweet.include?(word)
  end
  return clue.empty?
end

def parse_tweet(tweet)
  tweeted_words = tweet.split(" ")
  non_special_tweeted_words = tweeted_words.select { |word| word[0] != '@' && word[0] != '#' }

  non_special_tweeted_words.join(" ")
end

def build_player_data
  client = twitter
  last_tweet_answered = BotData.last.last_tweet_read.to_i
  last_clue = Clue.all.order(:updated_at).last.status_id.to_i
  players = []

  tweets = client.mentions_timeline({:since_id => [last_tweet_answered, last_clue].min})
  tweets.each do |tweet|
    next if tweet.hashtags.length == 0

    code = tweet.hashtags.first.text
    player = tweet.uri().to_s.split('/')[3]

    clue = Clue.find_by(:code => code.upcase)
    next if clue.nil?

    player_idx = players.index {|p| p.handle == player}
    value = check_answer(tweet.text.downcase, clue.answer) ? clue.value : -clue.value

    if player_idx.nil?
      players.push(Player.new(player, value))
    else
      players[player_idx].score += value
    end
  end
  players
end

def respond_to_last_clue
  client = twitter
  last_clue = Clue.all.order(:updated_at).last
  players = build_player_data

  tweets = client.mentions_timeline({:since_id => last_clue.status_id})
  tweets.each do |tweet|
    next if tweet.hashtags.length == 0

    code = tweet.hashtags.first.text
    clue = Clue.find_by(:code => code.upcase)
    next if clue.nil?

    player_handle = tweet.uri().to_s.split('/')[3]
    guessed_answer = parse_tweet(tweet.text.downcase)
    correct_answer = clue.answer
    response = check_answer(tweet.text.downcase, clue.answer)

    player_idx = players.index {|p| p.handle == player_handle}
    total_value = players[player_idx].score

    tweet = "@#{player_handle} {code: ##{code}, guess: #{guessed_answer}, answer: #{correct_answer}, response: #{response}, total_score: #{total_value}}"[0...140]
    client.update(tweet)
  end
end

def tweet_new_clue
  clue = Clue.where(:tweeted => false).sample
  tweet = "#{clue.category}($#{clue.value}): #{clue.text} ##{clue.code}"

  client = twitter
  clue_tweet = client.update(tweet) if tweet.length <= 140

  clue.tweeted = true
  clue.status_id = clue_tweet.id
  clue.save
end

namespace :tweet do
  desc "Tweets an Untweeted Clue and Responds to Last Tweet"
  task clue: :environment do
    respond_to_last_clue
    tweet_new_clue
  end
  
  desc "Tweets the Daily Results"
  task results: :environment do
    client = twitter
    last_tweet_answered = BotData.last.last_tweet_read.to_i
    players = []
    
    tweets = client.mentions_timeline({:since_id => last_tweet_answered})
    tweets.each do |tweet|
      next if tweet.hashtags.length == 0
      
      code = tweet.hashtags.first.text
      player = tweet.uri().to_s.split('/')[3]
      
      clue = Clue.find_by(:code => code.upcase)
      next if clue.nil?
      
      player_idx = players.index {|p| p.handle == player}
      value = check_answer(tweet.text.downcase, clue.answer) ? clue.value : -clue.value
      
      if player_idx.nil?
        players.push(Player.new(player, value))
      else
        players[player_idx].score += value
      end
    end
    
    tweet = ""
    botData = nil
    last_tweet_read = tweets.sort {|a,b| a.id <=> b.id}.last.id
    
    if players.length > 0
      winner = players.sort_by {|obj| obj.score}.last.handle
      value = players.sort_by {|obj| obj.score}.last.score      
      tweet = "Todays winner is @#{winner} with a total of $#{value}. Number of contestants: #{players.length}"
      botData = BotData.new(:winner => winner, :num_players => players.length, :last_tweet_read => last_tweet_read.to_s)
    else
      tweet = "Nobody even played today. You should all be ashamed"
      botData = BotData.new(:last_tweet_read => last_tweet_read.to_s)
    end
    botData.save
    client.update(tweet)
  end
end
