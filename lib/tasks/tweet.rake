class Player
  attr_accessor :handle, :score
  
  def initialize(handle, score)
    @handle = handle
    @score = score
  end
end

def twitter
  Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
    config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
    config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
    config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
  end
end

def check_answer(tweet, clue)
  tweet.gsub!(/[^0-9a-z ]/, '')
  tweet.gsub!(/^(who |what |where |when )(is |are )(a |an |the )?|^(a |an |the )/, '')
  clue.gsub!(/[^0-9a-z ]/, '')
  clue.gsub!(/^(a |an |the )/, '')

  levenshtein_distance =  Levenshtein.distance(tweet, clue)
  levenshtein_distance <= 2 ? true : false
end

def parse_tweet(tweet)
  tweeted_words = tweet.split(" ")
  non_special_tweeted_words = tweeted_words.select { |word| word[0] != '@' && word[0] != '#' }

  non_special_tweeted_words.join(" ")
end

def build_player_data
  yesterdays_final_clue = BotData.last.last_tweet_read.to_i
  most_recent_clue = Clue.where(:tweeted => true).order(:updated_at).last.status_id.to_i
  tweets = twitter.mentions_timeline({:since_id => [yesterdays_final_clue, most_recent_clue].min})
  players = []

  tweets.each do |tweet|
    next if tweet.hashtags.length == 0

    code = tweet.hashtags.first.text
    clue = Clue.find_by(:code => code.upcase)
    next if clue.nil?

    player_handle = tweet.uri.to_s.split('/')[3]
    guess = parse_tweet(tweet.text).downcase
    answer = clue.answer
    value = check_answer(guess, answer) ? clue.value : -clue.value

    player_idx = players.index {|p| p.handle == player_handle}
    if player_idx.nil?
      players.push(Player.new(player_handle, value))
    else
      players[player_idx].score += value
    end
  end

  players
end

def respond_to_most_recent_clue
  most_recent_clue = Clue.where(:tweeted => true).order(:updated_at).last.status_id.to_i
  tweets = twitter.mentions_timeline({:since_id => most_recent_clue})
  players = build_player_data

  tweets.each do |tweet|
    next if tweet.hashtags.length == 0

    code = tweet.hashtags.first.text
    clue = Clue.find_by(:code => code.upcase)
    next if clue.nil?

    player_handle = tweet.uri.to_s.split('/')[3]
    answer = clue.answer
    guess = parse_tweet(tweet.text)
    response = check_answer(guess.dup.downcase, answer.dup)

    player_idx = players.index {|p| p.handle == player_handle}
    total_score = players[player_idx].score

    tweet = "@#{player_handle} {code: ##{code}, guess: #{guess}, answer: #{answer}, response: #{response}, total_score: #{total_score}}"[0...140]
    twitter.update(tweet)
  end
end

def tweet_new_clue
  begin
    clue = Clue.where(:tweeted => false).sample
    tweet = "#{clue.category}($#{clue.value}): #{clue.text} ##{clue.code}"
  end while tweet.length > 140

  clue.tweeted = true
  clue.status_id = twitter.update(tweet).id
  clue.save
end

namespace :tweet do
  desc "Tweets an Untweeted Clue and Responds to Last Tweet"
  task clue: :environment do
    begin
      respond_to_most_recent_clue
      tweet_new_clue
    rescue
      twitter.update("@RyanJPODonnell fix me please")
    end
  end
  
  desc "Tweets the Daily Results"
  task results: :environment do
    begin
      players = build_player_data
      most_recent_clue = Clue.where(:tweeted => true).order(:updated_at).last

      if players.length > 0
        champion = players.sort_by {|obj| obj.score}.last

        twitter.update("Todays winner is @#{champion.handle} with a total of $#{champion.score}. Number of contestants: #{players.length}")
        BotData.create(:winner => champion.handle, :num_players => players.length, :last_tweet_read => most_recent_clue.status_id)
      else
        twitter.update("Nobody even played today. You should all be ashamed")
        BotData.create(:last_tweet_read => most_recent_clue.status_id)
      end
    rescue
      twitter.update("@RyanJPODonnell fix me please")
    end
  end
end
