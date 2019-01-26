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
      tweet_details = TweetDetails.new(tweet)
      next if tweet_details.nil?

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
      tweet_details = TweetDetails.new(tweet)
      next if tweet_details.nil?

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

  private

  def recent_tweets(since)
    @client.mentions_timeline({
      :since_id => since,
      :count => 200,
    })
  end
end
