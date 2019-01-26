namespace :tweet do
  desc "Tweets an Untweeted Clue and Responds to Last Tweet"
  task clue: :environment do
    twitter_client = TwitterClient.new

    begin
      twitter_client.respond_to_most_recent_clue
      twitter_client.tweet_new_clue
    rescue
      twitter_client.update("@RyanJPODonnell fix me please")
    end
  end
  
  desc "Tweets the Daily Results"
  task results: :environment do
    twitter_client = TwitterClient.new

    begin
      twitter_client.tweet_summary
    rescue
      twitter_client.update("@RyanJPODonnell fix me please")
    end
  end
end
