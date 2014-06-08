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
  clue = clue.split(' ')
  clue_dup = clue.dup
  clue_dup.each do |word|
    clue.delete(word) if tweet.include?(word)
  end
  return clue.empty?
end

namespace :tweet do
  desc "Tweets an Untweeted Clue"
  task clue: :environment do
    clue = Clue.where(:tweeted => false).sample
    tweet = clue.category + ": " + clue.text + " #" + clue.code
    
    client = twitter
    client.update(tweet)
    clue.tweeted = true
    clue.save
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
      last_tweet_answered = tweet.uri().to_s.split('/')[5]
      
      clue = Clue.find_by(:code => code)
      next if clue.nil?
      
      player_idx = players.index {|p| p.handle == player}
      value = check_answer(tweet.text.downcase, clue.answer) ? clue.value : 0
      
      if player_idx.nil?
        players.push(Player.new(player, value))
      else
        players[player_idx].score += value
      end
    end
    
    tweet = ""
    botData = nil
    
    if players.length > 0
      winner = players.sort_by {|obj| obj.score}.last.handle
      value = players.sort_by {|obj| obj.score}.last.score      
      tweet = "Todays winner is @#{winner} with a total of $#{value}. Number of contestants: #{players.length}"
      botData = BotData.new(:winner => winner, :num_players => players.length, :last_tweet_read => last_tweet_answered.to_s)
    else
      tweet = "Nobody even played today. You should all be ashamed"
      botData = BotData.new(:last_tweet_read => last_tweet_answered.to_s)
    end
    botData.save
    client.update(tweet)
  end
end
