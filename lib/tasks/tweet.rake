namespace :tweet do
  desc "Tweets an Untweeted Clue"
  task clue: :environment do
    clue = Clue.where(:tweeted => false).sample
    tweet = clue.category + ": " + clue.text + " #" + clue.code
    
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = ENV["TWITTER_ACCESS_TOKEN"]
      config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
    end
  
    @client.update(tweet)
    clue.tweeted = true
    clue.save
  end
end
