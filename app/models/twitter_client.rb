class TwitterClient
  attr_reader :client

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  end

  def contestant_data
    contestants = {}

    since = [BotData.yesterdays_final_clue, BotData.most_recent_clue].min
    recent_tweets(since).each do |tweet|
      next if valid_tweet?(tweet) == false
      tweet_details = TweetDetails.new(tweet)

      player_handle = tweet_details.player_handle
      player = contestants[player_handle]
      if player.nil?
        player = Player.new(player_handle, tweet_details.value)
        contestants[player_handle] = player
      else
        contestants[player_handle].score += tweet_details.value
      end
    end

    contestants
  end

  def respond_to_most_recent_clue
    contestants = contestant_data
    since = BotData.most_recent_clue

    recent_tweets(since).each do |tweet|
      next if valid_tweet?(tweet) == false
      tweet_details = TweetDetails.new(tweet)

      player_handle = tweet_details.player_handle
      total_score = contestants[tweet_details.player_handle].score

      tweet = "@#{player_handle} {code: ##{tweet_details.code}, guess: #{tweet_details.guess}, answer: #{tweet_details.answer}, response: #{tweet_details.response}, total_score: #{total_score}}"[0...140]
      @client.update(tweet)
    end
  end

  def tweet_new_clue
    begin
      clue = Clue.where(:tweeted => false).sample
      tweet = "#{clue.category}($#{clue.value}): #{clue.text} ##{clue.code}"
    end while tweet.length > 140

    clue.tweeted = true
    clue.status_id = @client.update(tweet).id
    clue.save
  end

  def tweet_summary
    number_of_contestants = contestant_data.length

    if number_of_contestants > 0
      champion = contestant_data.values.sort{ |a, b|  b.score <=> a.score }.first

      @client.update("Todays winner is @#{champion.handle} with a total of $#{champion.score}. Number of contestants: #{number_of_contestants}")
      BotData.create(:winner => champion.handle, :num_players => number_of_contestants, :last_tweet_read => BotData.most_recent_clue.to_s)
    else
      @client.update("Nobody JEOP'd today! @ryanjpodonnell spice it up!")
      BotData.create(:last_tweet_read => BotData.most_recent_clue.to_s)
    end
  end

  private

  def recent_tweets(since)
    @client.mentions_timeline({
      :since_id => since,
      :count => 200,
    })
  end

  def valid_tweet?(tweet)
    hashtags = tweet.hashtags
    return false if hashtags.length == 0

    code = hashtags.first.text.upcase
    clue = Clue.find_by(:code => code)
    return false if clue.nil?

    true
  end
end
