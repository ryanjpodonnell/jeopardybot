namespace :tweet do
  desc "Tweets an Untweeted Clue and Responds to Last Tweet"
  task clue: :environment do
    begin
      twitter_client = TwitterClient.new

      twitter_client.respond_to_most_recent_clue
      twitter_client.tweet_new_clue
    rescue
      twitter_client.update("@RyanJPODonnell fix me please")
    end
  end
  
  desc "Tweets the Daily Results"
  task results: :environment do
    begin
      twitter_client = TwitterClient.new
      contestant_data = twitter_client.contestant_data
      number_of_contestants = contestant_data.length

      if number_of_contestants > 0
        puts contestant_data
        champion = contestant_data.values.sort{ |a, b|  b.score <=> a.score }.first

        # twitter_client.update("Todays winner is @#{champion.handle} with a total of $#{champion.score}. Number of contestants: #{number_of_contestants}")
        # BotData.create(:winner => champion.handle, :num_players => number_of_contestants, :last_tweet_read => BotData.most_recent_clue.to_s)
      # else
        # twitter_client.update("Nobody JEOP'd today! @ryanjpodonnell spice it up!")
        # BotData.create(:last_tweet_read => BotData.most_recent_clue.to_s)
      end
    rescue
      twitter_client.update("@RyanJPODonnell fix me please")
    end
  end
end
